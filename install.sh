#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure scripts have execute permission
chmod +x "$0" "$SCRIPT_DIR/install.sh" "$SCRIPT_DIR/uninstall.sh" "$SCRIPT_DIR"/*.command 2>/dev/null || true

OS_NAME="$(uname -s)"
if [ "$OS_NAME" = "Darwin" ]; then
    PLATFORM_LABEL="macOS"
else
    PLATFORM_LABEL="Linux"
fi

wait_on_error() {
    echo ""
    if [ -t 0 ]; then
        read -rp "Press Enter to close..." _
    elif [ -e /dev/tty ]; then
        read -rp "Press Enter to close..." _ </dev/tty 2>/dev/null || true
    fi
}

# Locate Node.js runtime (handling standard paths, user NVM/fnm/volta/pnpm under sudo)
find_node_dir() {
    if command -v node >/dev/null 2>&1; then
        local node_bin
        node_bin="$(command -v node)"
        echo "${node_bin%/*}"
        return 0
    fi
    for p in /opt/homebrew/bin /usr/local/bin /opt/local/bin; do
        if [ -f "$p/node" ] && [ -x "$p/node" ]; then
            echo "$p"
            return 0
        fi
    done
    local homes=()
    [ -n "$HOME" ] && homes+=("$HOME")
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        local sudo_home=""
        if command -v getent >/dev/null 2>&1; then
            local entry
            entry=$(getent passwd "$SUDO_USER" 2>/dev/null || true)
            if [ -n "$entry" ]; then
                local old_ifs="$IFS"
                IFS=:
                set -- $entry
                IFS="$old_ifs"
                sudo_home="$6"
            fi
        fi
        if [ -z "$sudo_home" ]; then
            sudo_home="$(eval echo "~$SUDO_USER" 2>/dev/null || true)"
        fi
        if [ -z "$sudo_home" ] || [ ! -d "$sudo_home" ]; then
            if [ "$OS_NAME" = "Darwin" ]; then
                sudo_home="/Users/$SUDO_USER"
            else
                sudo_home="/home/$SUDO_USER"
            fi
        fi
        [ "$sudo_home" != "$HOME" ] && homes+=("$sudo_home")
    fi
    for h in "${homes[@]}"; do
        [ -d "$h" ] || continue
        # Direct common paths
        for cand in \
            "$h/.local/bin" \
            "$h/bin" \
            "$h/.volta/bin" \
            "$h/.asdf/shims" \
            "$h/.local/share/mise/shims" \
            "$h/Library/pnpm" \
            "$h/.n/bin" \
            "$h/.local/share/pnpm" \
            "$h/.nvm/current/bin" \
            "$h/.local/share/fnm/current/bin" \
            "$h/.fnm/current/bin"; do
            if [ -f "$cand/node" ] && [ -x "$cand/node" ]; then
                echo "$cand"
                return 0
            fi
        done
        # NVM version directories (select latest version)
        local latest_nvm=""
        for nvm_node in "$h"/.nvm/versions/node/*/bin/node; do
            if [ -f "$nvm_node" ] && [ -x "$nvm_node" ]; then
                latest_nvm="$nvm_node"
            fi
        done
        if [ -n "$latest_nvm" ]; then
            echo "${latest_nvm%/*}"
            return 0
        fi
        # FNM version directories (select latest version)
        local latest_fnm=""
        for fnm_node in "$h"/.local/share/fnm/node-versions/*/installation/bin/node; do
            if [ -f "$fnm_node" ] && [ -x "$fnm_node" ]; then
                latest_fnm="$fnm_node"
            fi
        done
        if [ -n "$latest_fnm" ]; then
            echo "${latest_fnm%/*}"
            return 0
        fi
    done
    for p in /usr/bin /bin /usr/sbin /sbin; do
        if [ -f "$p/node" ] && [ -x "$p/node" ]; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

NODE_DIR=$(find_node_dir || true)
if [ -n "$NODE_DIR" ]; then
    export PATH="$NODE_DIR:$PATH"
fi

if ! command -v node >/dev/null 2>&1; then
    echo ""
    echo "[ERROR] Node.js was not found."
    echo "Antigravity Korean localization requires Node.js v16 or newer."
    echo "Install the latest LTS release from https://nodejs.org/."
    if [ "$OS_NAME" = "Darwin" ]; then
        echo "macOS users can also install it with Homebrew:"
        echo "  brew install node"
    else
        echo "Linux users can also use a package manager, for example: sudo apt install nodejs"
    fi
    wait_on_error
    exit 1
fi

# Check if target installation directory requires elevated permissions
set +e
node "$SCRIPT_DIR/localization_engine.js" --check-write "$@" >/dev/null 2>&1
CHECK_STATUS=$?
set -e

if [ "$CHECK_STATUS" -eq 2 ] && [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        echo "[INFO] Antigravity is installed in a system directory. Requesting elevated permission..."
        if [ -x "$SCRIPT_DIR/install.sh" ]; then
            exec sudo env "PATH=$PATH" "$SCRIPT_DIR/install.sh" "$@"
        else
            exec sudo env "PATH=$PATH" bash "$SCRIPT_DIR/install.sh" "$@"
        fi
    else
        echo "[ERROR] The target is a system directory and sudo is unavailable."
        echo "Run this script as root."
        wait_on_error
        exit 1
    fi
fi

# Parse brand title from arguments or prompt interactively
HAS_BRAND_ARG=false
for arg in "$@"; do
    if [ "$arg" = "--brand-title" ] || [[ "$arg" == --brand-title=* ]]; then
        HAS_BRAND_ARG=true
        break
    fi
done

BRAND_ARGS=()
if [ "$HAS_BRAND_ARG" = false ]; then
    echo ""
    echo "=========================================="
    echo "  Antigravity Korean Localization ($PLATFORM_LABEL)"
    echo "=========================================="
    echo ""
    echo "Choose how to display the product name:"
    echo "  [1] Keep the English name Antigravity (recommended)"
    echo "  [2] Hide the product name"
    echo ""
    CHOICE_VAL=""
    if [ -t 0 ]; then
        read -rp "Enter 1 or 2 (default: 1): " CHOICE_VAL
    fi
    case "$CHOICE_VAL" in
        2) BRAND_ARGS=(--brand-title hidden) ;;
        *) BRAND_ARGS=(--brand-title english) ;;
    esac
fi

echo ""
echo "[1/2] Installing Korean localization..."
if ! node "$SCRIPT_DIR/localization_engine.js" "${BRAND_ARGS[@]}" "$@"; then
    echo ""
    echo "[ERROR] Installation failed. Review the message above."
    if [ "$(id -u)" -ne 0 ]; then
        echo "If the message above reports a permission error or EACCES, run the script again with sudo."
        echo "Example: sudo ./install.sh"
    fi
    wait_on_error
    exit 1
fi

echo ""
echo "[2/2] Installation completed."
echo ""
echo "Korean localization has been installed."
echo "Restart Antigravity if it is not already open."
echo ""

for i in 5 4 3 2 1; do
    printf "\rThis window will close in %d seconds (press Enter to close now)... " "$i"
    if [ -t 0 ]; then
        read -t 1 -r && break || true
    else
        sleep 1
    fi
done
printf "\r\033[KDone.\n"
