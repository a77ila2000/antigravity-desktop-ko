#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

for node_dir in \
    "/opt/homebrew/bin" \
    "/usr/local/bin" \
    "/opt/local/bin" \
    "$HOME/.volta/bin" \
    "$HOME/.asdf/shims" \
    "$HOME/.local/share/mise/shims" \
    "$HOME/Library/pnpm" \
    "$HOME/.fnm/current/bin"
do
    if [ -d "$node_dir" ]; then
        PATH="$node_dir:$PATH"
    fi
done

if [ -s "$HOME/.nvm/nvm.sh" ] && ! command -v node >/dev/null 2>&1; then
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh" 2>/dev/null || true
fi

export PATH

if ! command -v node >/dev/null 2>&1; then
    echo "[ERROR] Node.js was not found."
    echo "Install the latest Node.js LTS release from https://nodejs.org/ or run: brew install node"
    read -rp "Press Enter to close..." _ </dev/tty 2>/dev/null || true
    exit 1
fi

exec /usr/bin/env bash "$SCRIPT_DIR/install.sh" "$@"
