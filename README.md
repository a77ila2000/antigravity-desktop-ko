# Antigravity 한국어 현지화 패치

Windows, macOS와 Linux용 Antigravity 데스크톱 앱의 제품 UI를 한국어로 표시하는 비공식 현지화 패치다. 한국어 번역이 안전하지 않은 기술 식별자와 스킬 고유 이름은 영어로 유지한다.

이 프로젝트는 [Silas-02/antigravity-desktop-cn](https://github.com/Silas-02/antigravity-desktop-cn)의 현지화 엔진을 기반으로 만든 한국어판이다.

## 공개 범위와 개인정보 보호

이 저장소에는 한글화에 필요한 번역 엔진, 사전, 설치·복구 스크립트와 재현 가이드만 포함한다. 다음 항목은 포함하지 않는다.

- API 키, 인증 토큰과 계정 정보
- Antigravity 프로젝트, 대화와 사용자 설정
- 로컬 경로가 포함된 검사 결과와 로그
- 번역 생성 캐시와 임시 작업 파일
- 개인 화면을 캡처한 이미지

자세한 Codex 작업 절차는 [ANTIGRAVITY-KOREAN-CODEX-GUIDE.md](./ANTIGRAVITY-KOREAN-CODEX-GUIDE.md)를 따른다.

## 확인된 호환성

- Antigravity 2.21.1: 실제 화면 검증 완료
- Antigravity 2.24.0: 핵심 `app.asar` 삽입 구조와 임시 복사본 설치 검증 완료
- Antigravity 2.25.0: 핵심 삽입 구조와 임시 복사본 설치 검증 완료, 새 라이선스·플러그인 배지 UI 번역 추가

Antigravity 업데이트는 `app.asar`를 교체하므로 업데이트 후 패치를 다시 적용해야 한다. 새 버전에서는 설치 전에 현재 구조를 반드시 검사한다.

## 주요 파일

- `localization_engine.js`: 사전 로드, 렌더러 주입과 Electron 원생 메뉴 패치 엔진
- `dicts/`: 영어·중국어 원문을 한국어 또는 안전한 영어로 바꾸는 내부 사전
- `install-korean-windows.bat`: Windows 설치
- `restore-original-windows.bat`: Windows 공식 원본 복구
- `install-korean-macos.command`: macOS 설치
- `restore-original-macos.command`: macOS 공식 원본 복구
- `install.sh`, `uninstall.sh`: macOS/Linux 설치와 복구
- `AGENTS.md`: Codex 개발·검증 안전 규칙
- `ANTIGRAVITY-KOREAN-CODEX-GUIDE.md`: 다른 PC에서 재현하는 전체 가이드

## 요구 사항

- Antigravity 데스크톱 앱
- Node.js 최신 LTS
- 설치 폴더에 쓸 수 있는 사용자 권한

관리자 권한은 기본값이 아니다. 일반 실행에서 권한 오류가 확인될 때만 사용한다.

## Windows 설치

1. Antigravity와 이 패치 폴더의 백업 상태를 가이드에 따라 확인한다.
2. `install-korean-windows.bat`을 더블클릭한다.
3. 제품명 선택에서 Enter를 누르면 영문 `Antigravity` 브랜드명이 유지된다.
4. 설치 완료 후 앱이 열리면 실제 메뉴를 확인한다.

자동 경로 탐지가 실패하면 패치 폴더의 PowerShell에서 다음 명령을 사용한다.

```powershell
node .\localization_engine.js --install-dir "$env:LOCALAPPDATA\Programs\antigravity" --brand-title english
```

## Windows 복구

`restore-original-windows.bat`을 더블클릭한다. 엔진이 `app.asar.bak`을 사용해 공식 원본을 복구한다.

자동 경로 탐지가 실패할 때만 다음 명령을 사용한다.

```powershell
node .\localization_engine.js --huifu --install-dir "$env:LOCALAPPDATA\Programs\antigravity"
```

백업에도 패치 마커가 있거나 앱 버전이 맞지 않으면 그 백업을 사용하지 말고 Antigravity 공식 설치 프로그램으로 복구한다.

## macOS와 Linux

macOS:

```bash
./install-korean-macos.command
./restore-original-macos.command
```

또는:

```bash
./install.sh
./uninstall.sh
```

Linux:

```bash
./install.sh
./uninstall.sh
```

권한 오류가 확인된 경우에만 `sudo`를 사용한다.

## 번역 정책

다음 제품 UI를 번역한다.

- 상단 메뉴와 트레이 메뉴
- 프로젝트·대화 메뉴
- 사이드바, 설정, 사용량과 작업 상태
- 업데이트, WSL 준비와 오류 대화상자

다음 항목은 원문을 유지한다.

- 사용자 입력과 모델 답변/사고 과정 본문
- 코드, 터미널 출력, 파일 경로와 명령
- URL, 모델명, API/MCP 이름과 기술 식별자
- `Skills` 제목과 스킬 고유 이름

한국어 번역이 없으면 중국어가 아니라 영어로 표시한다.

## 업데이트 후 다시 영어로 바뀐 경우

공식 업데이트가 패치를 제거한 정상 상태다.

1. 현재 `app.asar`에 패치 마커가 없는지 확인한다.
2. 예전 `app.asar.bak`이 남아 있으면 날짜가 붙은 이름으로 보존한다.
3. 현재 버전의 원생 메뉴와 렌더러 삽입 지점을 검사한다.
4. 새 버전에서 설치 파일을 다시 실행한다.

예전 `app.asar.bak`을 그대로 쓰면 새 버전에 예전 프로그램 코드를 되돌릴 수 있으므로 재사용하지 않는다.

## 사용자 데이터

대화와 프로젝트 데이터는 다음 위치에 있으며 패치 대상이 아니다.

```text
%USERPROFILE%\.gemini\antigravity
%APPDATA%\Antigravity
```

설치 또는 복구 과정에서 이 폴더를 삭제하지 않는다.

## 완료 확인

- `파일`, `보기`, `창` 상단 메뉴
- `예약된 작업`, `로컬` 사이드바/입력 영역
- `이름 바꾸기`, `읽지 않음으로 표시`, `복사`, `분할`, `보관`, `삭제` 대화 메뉴
- 설정과 사용량 화면에 중국어가 없는지 확인
- `Skills`와 스킬 고유 이름이 영어인지 확인
- 사용자 대화와 프로젝트가 유지되는지 확인

파일 마커만 보고 완료하지 말고 실제 화면을 확인한다.
