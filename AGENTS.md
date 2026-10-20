# Antigravity 한국어 현지화 프로젝트 작업 규칙

이 규칙은 이 저장소를 수정하는 모든 Codex 작업에 적용된다. 목표는 Antigravity의 기능, 사용자 데이터, 기술 식별자와 렌더링 성능을 손상하지 않으면서 자연스러운 한국어 UI를 제공하는 것이다.

## 1. 기준과 호환성

- 저장소의 실제 파일과 현재 설치된 Antigravity 패키지를 최종 기준으로 삼는다.
- 마지막 실제 화면 검증 버전은 2.21.1이며, 2.24.0에서는 핵심 삽입 구조와 임시 복사본 설치의 정적 호환성을 확인했다.
- 업데이트 작업을 시작하기 전에 현재 앱 버전과 `app.asar` 구조를 다시 검사한다. 예전 버전의 백업이나 압축 해제 결과를 새 버전에 재사용하지 않는다.
- 엔진은 `dicts/*.json`을 파일명 순서로 모두 읽는다. 중국어 원문 키는 화면에 남은 중국어를 감지해 한국어나 영어로 바꾸는 내부 호환 데이터이므로 임의로 삭제하지 않는다.
- 사용자용 문서, 파일명과 설치 메시지는 한국어 또는 영어만 사용한다.

## 2. 번역 범위

- 번역 대상: 제품의 고정 메뉴, 버튼, 제목, 설명, 알림, 상태 문구와 설정 UI.
- 번역 금지: 사용자 입력, 모델 답변과 사고 과정 본문, 코드, 터미널 출력, 로그, URL, 파일 경로, 명령, 단축키, 키·토큰, 모델명, 제품명, MCP/API 키, 환경 변수와 오류 코드.
- 번역할 수 없는 제품 문구는 중국어가 아니라 영어 원문으로 유지한다.
- `Skills` 제목과 스킬 고유 이름은 영어로 유지한다. 스킬 설명은 기술 식별자를 훼손하지 않는 범위에서 한국어로 표시할 수 있다.
- `agent`는 `에이전트`, `conversation`은 `대화` 또는 `대화 세션`, `project`는 `프로젝트`, `workspace`는 `작업 공간`, `worktree`는 `작업 트리`로 통일한다.
- 버튼과 짧은 라벨 끝에는 마침표를 붙이지 않는다. 한국어 문장에는 한국어 문장 부호를 사용하고, 버전·파일 확장자 같은 기술 표기는 원문 형식을 유지한다.

## 3. 사전 규칙

- 사전 키는 실제 앱에서 확인한 영어 원문과 1:1로 대응해야 한다. 추측으로 공백·마침표 변형 키를 여러 개 만들지 않는다.
- `Skill`, `Plugin`, `Command`처럼 짧고 범용적인 단어를 전역 사전에 추가하지 않는다. 코드나 경로까지 오염될 수 있다.
- 고유 스킬 이름은 `SKILL_PICKER_DISPLAY_ENTRIES`에서 문맥 제한 방식으로 처리한다.
- 동적 숫자, 시간, 날짜, 프로젝트명과 파일명은 값 자체를 하드코딩하지 않고 경계가 명확한 정규식 캡처로 보존한다.

## 4. 렌더링과 원생 메뉴

- DOM 번역은 사용자 입력 영역, 코드 편집기, 터미널, `contenteditable`, `data-testid="user-input-step"`와 `data-ag-localization-skip` 경계를 넘지 않는다.
- 아이콘, SVG, 링크, 버튼 이벤트, ARIA 속성과 React 내부 구조를 보존한다. 광범위한 `innerHTML` 또는 컨테이너 전체 `textContent` 교체를 사용하지 않는다.
- 번역은 멱등적이어야 하며, `MutationObserver`는 변경된 노드 중심으로 처리한다. 전체 화면 주기 스캔을 추가하지 않는다.
- 대화 더보기 메뉴는 렌더러 DOM과 Electron 원생 메뉴 경로가 모두 존재할 수 있다. `dist/ipcHandlers.js`의 `buildContextMenuTemplate()`, `Menu.buildFromTemplate()`, `menu.popup()`과 두 개의 라벨 경로를 함께 확인한다.
- 실제 화면을 확인하지 않고 사전 또는 DOM 한 경로만 보고 완료 처리하지 않는다.

## 5. `localization_engine.js` 템플릿 안전

- `generateJs()`는 큰 템플릿 문자열로 `preload.js` 코드를 만든다. 엔진 외부 문법 검사만으로는 생성 코드 오류를 잡을 수 없다.
- 템플릿 안에서 작은따옴표가 포함된 영어 문자열은 큰따옴표 또는 `JSON.stringify()`를 사용한다.
- 템플릿 안 정규식의 `\s`, `\d`, `\w`와 경로 역슬래시는 외부 템플릿 평가를 고려해 이중 이스케이프한다.
- 수정 후 다음 두 검사를 모두 실행한다.

```powershell
node --check .\localization_engine.js
node -e 'const fs=require("fs"); const vm=require("vm"); const code=fs.readFileSync("localization_engine.js","utf8"); const testCode=code.replace(/main\(\);?\s*$/, "const c=generateJs(); new vm.Script(c); console.log(\"[OK] generated preload syntax\");"); eval(testCode);'
```

## 6. 작업 순서

1. `git status --short --untracked-files=all`로 기존 변경을 확인하고 보존한다.
2. 현재 설치 버전과 `app.asar`, `app.asar.bak` 및 패치 마커를 확인한다.
3. 공식 패키지는 별도 임시 폴더에 읽기 전용으로 풀어 현재 삽입 지점을 확인한다.
4. 필요한 사전 또는 엔진 규칙만 최소 범위로 수정한다.
5. 모든 JSON을 `JSON.parse()`로 검사하고 엔진/생성 코드 문법을 검사한다.
6. `git diff --check`, `git diff`와 `git status`로 의도하지 않은 변경을 확인한다.
7. 설치 뒤에는 상단 메뉴, 사이드바, 원생/DOM 대화 메뉴, 설정, 사용량, Skills 화면과 작업 상태를 실제로 확인한다.

## 7. 설치와 복구 안전 규칙

- 개발 중 Codex가 `localization_engine.js`, 설치·복구 스크립트를 직접 실행해 설치 폴더를 수정하지 않는다. 검사와 준비를 끝낸 뒤 사용자가 공식 진입 파일을 실행하도록 안내한다.
- Windows 설치: `install-korean-windows.bat`
- Windows 복구: `restore-original-windows.bat`
- macOS 설치: `install-korean-macos.command` 또는 `./install.sh`
- macOS 복구: `restore-original-macos.command` 또는 `./uninstall.sh`
- Linux 설치/복구: `./install.sh`, `./uninstall.sh`
- 권한 오류가 확인된 경우에만 관리자 권한 또는 `sudo`를 사용한다.
- `app.asar.bak`이 있으면 엔진은 항상 그 파일을 원본으로 사용한다. 공식 업데이트 후 현재 `app.asar`에 패치 마커가 없는데 예전 백업이 남아 있으면 백업을 날짜가 붙은 이름으로 보존하고 새 버전에서 새 백업이 만들어지게 한다.
- 현재 `app.asar`와 백업에 모두 패치 마커가 있거나 정상 원본 백업이 없으면 공식 설치 프로그램으로 앱을 복구한 뒤 다시 진행한다.
- `%USERPROFILE%\.gemini\antigravity`와 `%APPDATA%\Antigravity`는 수정하거나 삭제하지 않는다.

## 8. 파일 형식과 Git

- `*.bat`은 ASCII 또는 UTF-8 영문 메시지만 사용하고 CRLF 줄바꿈을 유지한다.
- `*.sh`와 `*.command`의 LF 및 실행 권한을 유지한다. Windows의 가짜 권한 변경이 커밋되지 않도록 `core.filemode=false`를 유지한다.
- 사용자의 명시적 요청 없이 stage, commit, push, tag, rebase 또는 기록 재작성을 하지 않는다.
- 완료 보고에는 변경 파일, 대상 앱 버전, 원본 백업 상태, 정적 검사, 실제 화면 확인 결과와 남은 제한을 포함한다.
