# Antigravity Windows 한글화 재현 가이드 (Codex용)

작성일: 2026-10-15  
대상: Windows용 Antigravity 데스크톱 앱  
목적: 이 폴더의 한글화 패치를 다른 PC의 Codex가 안전하게 재현하고, 실제 화면까지 검증하도록 한다.

## 1. 검증 범위와 핵심 원칙

- 실제 화면 한글화는 Antigravity 2.21.1에서 검증했다.
- 2026-10-17 현재 Antigravity 2.24.0 공식 `app.asar`를 읽기 전용으로 검사했고, 현재 엔진이 사용하는 핵심 삽입 지점과 임시 복사본 설치가 정상 동작하는 것을 확인했다.
  - `buildContextMenuTemplate()` 1개
  - `label: item.label ?? ''` 2개(일반 항목과 중첩 하위 메뉴)
  - `Menu.buildFromTemplate()` 및 `menu.popup()` 경로 존재
  - 상단 메뉴, 트레이, 업데이트 창, WSL 안내용 삽입 지점 존재
- 향후 버전에서는 구조가 바뀔 수 있으므로 **설치 명령부터 실행하지 말고 현재 버전과 삽입 지점을 먼저 검사한다.**
- 공식 업데이트는 `app.asar`를 교체한다. 업데이트 후에는 예전 버전의 `app.asar.bak`을 절대로 그대로 재사용하지 않는다.
- 한글화는 설치 파일만 수정한다. 아래 사용자 데이터는 삭제하거나 초기화하지 않는다.
  - `%USERPROFILE%\.gemini\antigravity` — 프로젝트, 대화 DB, 작업 산출물
  - `%APPDATA%\Antigravity` — 화면 배치와 앱 UI 상태
- 번역이 없는 문구는 영어로 남긴다. 중국어로 대신 표시하지 않는다.
- 사용자가 요청한 정책에 따라 `Skills` 제목과 스킬 고유 이름은 영어로 유지한다. 제품 UI 설명은 안전한 범위에서 한국어로 표시한다.
- 사용자 입력, 모델 답변 본문, 사고 과정 본문, 코드, 터미널 출력, 경로, 명령어, URL, 모델명과 스킬 기술 식별자는 번역하지 않는다.

## 2. 다른 PC로 반드시 복사할 항목

이 파일 하나만 복사하면 안 된다. 다음 폴더 전체를 다른 PC로 복사한다.

```text
antigravity-desktop-ko-20261006\
├─ AGENTS.md
├─ ANTIGRAVITY-KOREAN-CODEX-GUIDE.md
├─ localization_engine.js
├─ dicts\
│  ├─ ko_*.json
│  ├─ zz_ko_*.json
│  └─ zz_zh_to_ko.json
├─ install-korean-windows.bat / restore-original-windows.bat
├─ install-korean-macos.command / restore-original-macos.command
└─ install.sh / uninstall.sh
```

`localization_engine.js`만 복사하면 사전이 누락되어 불완전하게 번역된다. 중국어 원본 사전도 엔진의 기반 데이터이므로 임의로 삭제하지 않는다. 파일 이름이 `zz_`로 시작하는 한국어 사전이 마지막에 로드되어 중국어 결과를 덮어쓰는 구조다.

## 3. 다른 PC의 Codex에 그대로 넣을 작업 지시문

다른 PC에서 Codex로 이 폴더를 연 다음 아래 내용을 한 번에 붙여 넣는다.

```text
이 폴더의 AGENTS.md와 ANTIGRAVITY-KOREAN-CODEX-GUIDE.md를 처음부터 끝까지 읽고 그대로 수행해줘.

목표는 현재 Windows PC에 설치된 Antigravity를 이 폴더의 한국어 패치로 준비하고, 사용자가 공식 Windows 설치 배치 파일을 한 번 실행한 뒤 정적 검사와 실제 화면 검증까지 완료하는 것이다.

필수 조건:
1. 현재 설치 경로와 버전을 직접 찾고, 공식 app.asar 구조를 먼저 검사한다.
2. %USERPROFILE%\.gemini\antigravity 및 %APPDATA%\Antigravity는 수정·삭제하지 않는다.
3. 현재 app.asar가 공식 원본인지 패치본인지 마커로 판별한다.
4. 공식 업데이트 뒤 남은 오래된 app.asar.bak은 재사용하지 말고 별도 이름으로 보존한 뒤 현재 공식 app.asar에서 새 백업이 만들어지게 한다.
5. 현재 app.asar가 이미 패치됐는데 정상 원본 백업이 없다면 덮어쓰지 말고 Antigravity 공식 복구/재설치로 원본을 확보한다.
6. localization_engine.js 외부 문법, generateJs()로 생성되는 preload 코드, 모든 JSON 사전을 설치 전에 검사한다.
7. 현재 버전에서 삽입 지점이 달라졌다면 localization_engine.js를 최소 범위로 수정한 다음 다시 검사한다. 특히 dist/ipcHandlers.js의 일반 메뉴와 중첩 하위 메뉴 라벨 경로 둘 다 처리한다.
8. 저장소 규칙에 따라 Codex가 설치 엔진이나 설치 배치 파일을 직접 실행하지 않는다. 준비와 검사를 마치면 내가 `install-korean-windows.bat`을 한 번 실행하도록 정확히 안내하고, 브랜드 선택은 기본값 1(영문 Antigravity)을 사용하게 한다.
9. 내가 배치 파일 실행 완료를 알리면 파일 마커만 확인하고 끝내지 말고 앱을 실행해 상단 메뉴, 사이드바, 대화 더보기 메뉴, 설정/사용량, Skills 화면, 작업 상태를 실제로 확인한다.
10. 중국어가 한 글자라도 제품 UI에 남아 있으면 원문과 렌더링 위치를 확인해 한국어로 번역하고, 자연스러운 번역이 어렵거나 기술 식별자라면 영어로 유지한다.
11. 사용자 입력과 모델 답변/사고 과정, 코드, 터미널, 파일 경로는 번역하지 않는다.
12. 성공 보고에는 앱 버전, 설치 경로, 원본 백업 상태, 실행한 검증, 실제로 확인한 한국어 메뉴, 남은 제한을 포함한다.

가이드의 PowerShell 명령을 기준으로 진행하되, 다른 사용자 이름이나 설치 경로를 하드코딩하지 말고 환경 변수로 찾는다. 중간에 단순 확인을 위해 나에게 묻지 말고 안전한 범위에서 계속 진행한다. 설치 배치 파일 실행, 관리자 권한 또는 계정 입력처럼 내가 직접 해야 하는 경우만 정확히 알려줘.
```

## 4. Codex 실행 절차

### 4.1 작업 규칙과 현재 변경 상태 확인

```powershell
Get-Content -LiteralPath .\AGENTS.md -Raw
git status --short --untracked-files=all
```

Git 저장소가 아닌 복사본이면 두 번째 명령은 생략할 수 있다. 기존 파일을 자동 정리하거나 원격 저장소 상태로 되돌리지 않는다.

### 4.2 필수 프로그램과 설치 위치 확인

```powershell
$agInstall = Join-Path $env:LOCALAPPDATA 'Programs\antigravity'
$agExe = Join-Path $agInstall 'Antigravity.exe'
$agResources = Join-Path $agInstall 'resources'
$agAsar = Join-Path $agResources 'app.asar'
$agBak = Join-Path $agResources 'app.asar.bak'

node --version
npm --version

if (!(Test-Path -LiteralPath $agExe)) { throw "Antigravity.exe를 찾지 못했습니다: $agExe" }
if (!(Test-Path -LiteralPath $agAsar)) { throw "app.asar를 찾지 못했습니다: $agAsar" }

$agFile = Get-Item -LiteralPath $agExe
[pscustomobject]@{
    ProductVersion = $agFile.VersionInfo.ProductVersion
    FileVersion    = $agFile.VersionInfo.FileVersion
    InstallPath    = $agInstall
} | Format-List

Get-FileHash -LiteralPath $agAsar -Algorithm SHA256
if (Test-Path -LiteralPath $agBak) {
    Get-FileHash -LiteralPath $agBak -Algorithm SHA256
}
```

Node.js가 없으면 최신 LTS 버전을 설치한 다음 새 PowerShell에서 계속한다.

### 4.3 대화 데이터 안전 백업

패치가 사용자 데이터를 건드리지는 않지만, 다른 PC에서 최초 작업할 때는 대화 폴더를 한 번 백업한다. 백업에는 개인 대화가 포함되므로 클라우드나 공개 저장소에 올리지 않는다.

```powershell
$agConversationData = Join-Path $env:USERPROFILE '.gemini\antigravity'
$agBackupRoot = Join-Path ([Environment]::GetFolderPath('MyDocuments')) ("Antigravity-user-backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))

if (Test-Path -LiteralPath $agConversationData) {
    New-Item -ItemType Directory -Path $agBackupRoot | Out-Null
    Copy-Item -LiteralPath $agConversationData -Destination $agBackupRoot -Recurse
    Get-ChildItem -LiteralPath $agBackupRoot -Force
}
```

### 4.4 공식 원본과 오래된 백업 판별

패치 마커는 이름에 `CHINESE`가 남아 있지만, 현재 한국어 패치도 같은 기존 마커를 사용한다.

```powershell
$agPatchMarker = '__ANTIGRAVITY_CHINESE_LOCALIZATION_START__'
$agCurrentPatched = [bool](rg -a -l -F $agPatchMarker -- $agAsar)
$agBackupPatched = $false
if (Test-Path -LiteralPath $agBak) {
    $agBackupPatched = [bool](rg -a -l -F $agPatchMarker -- $agBak)
}

[pscustomobject]@{
    CurrentAsarPatched = $agCurrentPatched
    BackupExists       = Test-Path -LiteralPath $agBak
    BackupPatched      = $agBackupPatched
} | Format-List
```

판정은 다음과 같이 한다.

| 현재 `app.asar` | `app.asar.bak` | 조치 |
|---|---|---|
| 공식 원본(마커 없음) | 없음 | 그대로 진행한다. 설치 엔진이 새 원본 백업을 만든다. |
| 공식 원본(마커 없음) | 있음 | 공식 업데이트 뒤 남은 구버전일 수 있다. 기존 백업을 날짜가 붙은 이름으로 보존한 뒤 진행한다. |
| 패치본(마커 있음) | 마커 없는 백업 있음 | 정상 상태다. 해당 백업을 원본으로 재설치할 수 있다. |
| 패치본(마커 있음) | 백업 없음 또는 백업도 패치됨 | 중단하고 Antigravity 공식 설치 프로그램으로 복구/재설치한 뒤 다시 검사한다. |

공식 원본인데 기존 백업이 남아 있는 경우에만 다음처럼 보존한다. 대상이 정확히 `$agBak`인지 확인하고 실행한다.

```powershell
if (!$agCurrentPatched -and (Test-Path -LiteralPath $agBak)) {
    $agStaleBak = Join-Path $agResources ("app.asar.bak.stale-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Move-Item -LiteralPath $agBak -Destination $agStaleBak
    Write-Output "이전 백업 보존 위치: $agStaleBak"
}
```

이 절차가 중요한 이유는 설치 엔진이 `app.asar.bak`이 있으면 항상 그 파일을 원본으로 사용하기 때문이다. 업데이트 후 구버전 백업을 그대로 두면 새 앱에 예전 코드를 다시 넣을 수 있다.

### 4.5 현재 버전의 `app.asar` 구조 검사

임시 폴더에 공식 패키지를 풀고 예상 삽입 지점을 확인한다. 설치 폴더에는 아직 쓰지 않는다.

```powershell
$agInspect = Join-Path $env:TEMP ("antigravity-asar-inspect-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $agInspect | Out-Null
npx --yes @electron/asar extract $agAsar $agInspect

$agIpc = Join-Path $agInspect 'dist\ipcHandlers.js'
$agMenu = Join-Path $agInspect 'dist\menu.js'
$agTray = Join-Path $agInspect 'dist\tray.js'

rg -n -F 'function buildContextMenuTemplate(items, onSelect) {' $agIpc
rg -n -F "label: item.label ?? ''," $agIpc
rg -n -F 'Menu.buildFromTemplate' $agIpc
rg -n -F '.popup(' $agIpc
rg -n -F 'electron_1.Menu.setApplicationMenu(menu);' $agMenu
rg -n 'function\s+createTray\s*\(' $agTray
rg -n -F 'function insertTrayMenuItem(position, options) {' $agTray
```

정상 기준:

- `buildContextMenuTemplate()`가 1개 있어야 한다.
- `label: item.label ?? ''`가 정확히 2개 있어야 한다.
- 두 라벨 경로 모두 `translateNativeContextMenuLabel(...)`로 바뀌도록 엔진이 작성되어 있어야 한다.
- `Menu.buildFromTemplate()`와 `.popup()`이 있어야 한다.
- `menu.js`의 `setApplicationMenu` 삽입 지점이 있어야 한다.
- 구조가 다르면 설치부터 하지 말고 현재 압축 해제본을 기준으로 `localization_engine.js`의 해당 패치 부분만 최소 수정한다.

검사가 끝난 임시 폴더는 최종 검증 후 삭제하거나 휴지통으로 이동한다.

### 4.6 설치 전 문법과 사전 검사

```powershell
node --check .\localization_engine.js

node -e 'const fs=require("fs"); for(const f of fs.readdirSync("dicts").filter(x=>x.endsWith(".json"))){JSON.parse(fs.readFileSync("dicts/"+f,"utf8")); console.log("JSON OK:",f);}'

node -e 'const fs=require("fs"); const vm=require("vm"); const code=fs.readFileSync("localization_engine.js","utf8"); const testCode=code.replace(/main\(\);?\s*$/, "const c=generateJs(); new vm.Script(c); console.log(\"[OK] generated preload syntax\");"); eval(testCode);'
```

세 검사가 모두 성공해야 설치한다. 특히 마지막 검사는 거대한 템플릿 문자열 내부에서 역슬래시나 따옴표가 손상되는 문제를 잡는다.

### 4.7 한글화 설치 — 사용자가 한 번 실행

저장소 규칙상 Codex는 실제 앱을 수정하는 설치 엔진이나 배치 파일을 직접 실행하지 않는다. 4.1~4.6 검사를 모두 마친 뒤 사용자가 탐색기에서 다음 파일을 더블클릭한다.

```text
install-korean-windows.bat
```

설치 화면의 선택 의미는 다음과 같다.

- `1`: 영어 `Antigravity` 브랜드명 유지 — 기본값이며 권장
- `2`: 브랜드명 숨김

아무것도 입력하지 않고 Enter를 누르면 `1`이 선택된다. 설치 경로 자동 감지가 실패할 때만 Codex가 현재 설치 경로를 확인한 뒤 사용자에게 다음 명령을 직접 실행하도록 제공한다.

```powershell
node .\localization_engine.js --install-dir "$env:LOCALAPPDATA\Programs\antigravity" --brand-title english
```

정상 동작:

- 실행 중인 Antigravity 프로세스를 감지하면 엔진이 종료를 시도한다.
- `resources\app.asar.bak`이 없으면 현재 공식 원본으로 새 백업을 만든다.
- `dist/preload.js`, `dist/ipcHandlers.js`, `dist/menu.js`, 트레이/업데이트/WSL 관련 파일을 메모리에서 패치한다.
- 성공하면 Antigravity를 다시 실행한다.

출력에 `[WARNING]`이 하나라도 나오면 성공으로 간주하지 않는다. 특히 `ipcHandlers.js` 또는 `menu.js` 삽입 지점 경고는 현재 버전에 맞게 엔진을 수정해야 한다는 뜻이다.

권한 오류가 날 때만 배치 파일을 마우스 오른쪽 버튼으로 눌러 `관리자 권한으로 실행`한다.

### 4.8 설치 파일 정적 검증

```powershell
$agAsar = Join-Path $env:LOCALAPPDATA 'Programs\antigravity\resources\app.asar'
$agBak = Join-Path $env:LOCALAPPDATA 'Programs\antigravity\resources\app.asar.bak'

rg -a -l -F '__ANTIGRAVITY_CHINESE_LOCALIZATION_START__' -- $agAsar
rg -a -l -F 'nativeContextMenuTranslations' -- $agAsar

if (!(Test-Path -LiteralPath $agBak)) { throw '공식 원본 백업이 없습니다.' }
if (rg -a -l -F '__ANTIGRAVITY_CHINESE_LOCALIZATION_START__' -- $agBak) {
    throw '원본 백업에 패치 마커가 있습니다. 이 백업으로 복구하면 안 됩니다.'
}

Get-FileHash -LiteralPath $agAsar -Algorithm SHA256
Get-FileHash -LiteralPath $agBak -Algorithm SHA256
```

더 엄격히 확인하려면 설치된 `app.asar`를 새 임시 폴더에 다시 풀어 다음을 검사한다.

- `dist/preload.js`: 패치 시작/종료 마커가 각각 1개
- `dist/ipcHandlers.js`: `nativeContextMenuTranslations` 1개, `translateNativeContextMenuLabel`이 적용된 라벨 경로 2개
- `dist/menu.js`: 원생 상단 메뉴 번역 마커 존재
- 추출된 세 JavaScript 파일 모두 `node --check` 통과

### 4.9 실제 화면 검증 — 반드시 수행

정적 검증만으로 완료 처리하지 않는다. 다음 화면을 직접 열고 확인한다.

1. 상단 메뉴
   - `파일`, `보기`, `창`
   - 하위 항목 `새 대화`, `프로젝트 만들기`, `명령 팔레트`, `설정`
2. 왼쪽 사이드바와 입력 영역
   - `예약된 작업`
   - 실행 환경 `로컬`
3. 프로젝트의 대화 항목 `⋮` 메뉴
   - `이름 바꾸기`
   - `읽지 않음으로 표시` 또는 `읽음으로 표시`
   - `복사`
   - `분할`
   - `보관` 또는 `보관 해제`
   - `삭제`
4. 설정과 사용량 화면
   - 설명 문장과 남은 한도/초기화 시간이 한국어 또는 영어
   - 중국어 문장이 없어야 함
5. Skills 화면
   - 제목 `Skills`
   - 스킬 고유 이름은 영어
   - `기술`처럼 어색하게 번역된 제목이나 중국어 스킬명이 없어야 함
6. 대화 작업 상태
   - `작업 중...`, `검색 중...`, `생각 중: 1초` 등 제품 상태는 한국어
   - 모델의 사고 과정이나 답변 본문은 원문을 유지

Electron의 원생 메뉴와 웹 렌더러 메뉴는 서로 다른 코드 경로다. 비슷한 메뉴 하나만 확인하고 전체가 됐다고 판단하지 않는다.

## 5. 자주 발생했던 실패와 정확한 해결법

### 업데이트 후 모든 메뉴가 다시 영어가 됨

정상적인 현상이다. 공식 업데이트가 `app.asar`를 교체한다.

1. 새 버전과 현재 `app.asar`가 공식 원본인지 확인한다.
2. 남아 있는 구버전 `app.asar.bak`을 날짜가 붙은 이름으로 보존한다.
3. 현재 버전의 삽입 지점을 다시 검사한다.
4. 설치 엔진을 다시 실행해 새 버전용 원본 백업을 만든다.

### 설치 명령은 성공했지만 대화 더보기 메뉴가 영어임

DOM 사전만 수정해서는 해결되지 않는다. `dist/ipcHandlers.js`의 Electron 원생 메뉴를 확인한다.

- `buildContextMenuTemplate()`
- `Menu.buildFromTemplate()`
- `menu.popup()`
- `label: item.label ?? ''` 두 경로

일반 항목과 중첩 하위 메뉴의 두 라벨 모두 `translateNativeContextMenuLabel()`을 거쳐야 한다.

### 중국어가 남거나 한글 대신 중국어가 나타남

- `dicts\zz_ko_*.json`과 `dicts\zz_zh_to_ko.json`이 누락되지 않았는지 확인한다.
- 원본 중국어 사전을 무작정 삭제하지 않는다. 한국어 `zz_` 사전이 후순위로 덮어쓰는 구조다.
- 동적 도우미가 중국어를 생성하면 해당 영어 원문에 한국어 매핑이 있을 때만 한국어를 사용하고, 안전한 매핑이 없으면 영어 원문으로 되돌린다.
- 화면에서 보인 중국어의 정확한 원문, 위치와 DOM 범위를 확인한 뒤 제한된 규칙을 추가한다.

### `Skills`가 `기술`로 표시되거나 스킬 이름이 중국어임

- `zz_ko_page_agents.json`에서 `Skills`와 `Installed Skills`를 영어로 유지한다.
- `SKILL_PICKER_DISPLAY_ENTRIES`의 `display` 값은 영어 이름을 사용한다.
- 전역 사전에 `Skill`, `Plugin`, `Command` 같은 짧고 범용적인 단어를 추가하지 않는다. 코드·경로·기술 식별자까지 잘못 번역될 수 있다.

### 작업 과정/모델 답변이 섞여 번역됨

- 짧은 독립 영단어 사전 매핑을 사용하지 않는다.
- 사고 과정 본문과 사용자 입력 영역을 번역 차단 구역으로 유지한다.
- `Thinking for ...`처럼 제품이 그리는 상태 헤더만 번역한다.

### 패치 후 앱이 실행되지 않음

우선 공식 백업이 정상인지 확인한 다음 사용자가 탐색기에서 다음 파일을 더블클릭한다.

```text
restore-original-windows.bat
```

자동 경로 감지가 실패하는 경우에만 Codex가 경로를 확인하고, 사용자에게 다음 복구 명령을 직접 실행하도록 제공한다.

```powershell
node .\localization_engine.js --huifu --install-dir "$env:LOCALAPPDATA\Programs\antigravity"
```

백업에도 패치 마커가 있거나 버전이 맞지 않으면 그 백업을 사용하지 말고 Antigravity 공식 설치 프로그램으로 복구/재설치한다. 사용자 데이터 폴더는 삭제하지 않는다.

## 6. 완료 판정

다음 조건을 모두 충족해야 완료다.

- 현재 앱 버전과 설치 경로를 기록했다.
- 공식 원본 `app.asar.bak`이 존재하고 패치 마커가 없다.
- 외부 엔진 문법, 생성된 preload 문법, 모든 JSON이 통과했다.
- 현재 버전의 원생 메뉴 삽입 구조를 확인했다.
- 설치 로그에 삽입 실패 경고가 없다.
- 설치된 `app.asar`에 렌더러와 원생 메뉴 패치 마커가 있다.
- 실제 화면에서 상단 메뉴와 대화 더보기 메뉴를 각각 확인했다.
- 제품 UI에 중국어가 남지 않았다.
- `Skills` 제목과 스킬 이름은 영어로 표시된다.
- 사용자 대화와 프로젝트 데이터가 그대로 남아 있다.

## 7. Codex 완료 보고 형식

```text
Antigravity 버전:
설치 경로:
패치 폴더:
원본 백업 경로 및 SHA-256:
패치된 app.asar SHA-256:
현재 버전 구조 검사 결과:
문법/JSON 검사 결과:
실제로 확인한 한국어 메뉴:
Skills 영어 유지 확인:
중국어 잔존 확인:
사용자 데이터 보존 확인:
남은 제한 또는 확인하지 못한 항목:
```

확인하지 못한 화면을 추측해서 성공으로 적지 않는다.
