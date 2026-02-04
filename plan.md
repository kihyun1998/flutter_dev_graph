# flutter_dev_graph 계획서 (v4)

## 목표

Flutter/Dart 프로젝트 → 의존성 그래프 출력 (feature 기반 그룹핑 지원)

---

## 개발 방식

- 기능 하나씩 점진적으로 추가
- 매 버전마다 실행 가능한 상태 유지
- 구현 → 확인 → 피드백 → 다음 기능

---

## 버전별 구현 계획

### v0.0.1 - 프로젝트 셋업 ✅
- [x] dart create로 패키지 생성
- [x] pubspec.yaml 설정 (executables: fdg)
- [x] bin/fdg.dart 진입점 생성
- [x] 실행하면 "Hello fdg" 출력

**확인**: `dart run bin/fdg.dart` 실행되는지 ✅

---

### v0.0.2 - 파일 스캐너 ✅
- [x] 경로 받아서 `.dart` 파일 목록 수집
- [x] `lib/` 폴더 기준 스캔
- [x] 생성파일 제외 (`.g.dart`, `.freezed.dart`)
- [x] 결과를 콘솔에 출력

**확인**: 다른 Flutter 프로젝트 경로 넣으면 파일 목록 나오는지 ✅

---

### v0.0.3 - Import 파서 ✅
- [x] 각 파일 읽어서 import 문 추출
- [x] 상대 경로 → 절대 경로 변환
- [x] `package:` import 중 내부 패키지만 필터링
- [x] 외부 패키지 (flutter, third-party)는 제외
- [x] 결과: 파일별 import 목록 콘솔 출력

**확인**: 파일마다 어떤 파일을 import하는지 보이는지 ✅

---

### v0.0.4 - 그래프 모델 + JSON 출력 ✅
- [x] Node 모델 (id, path, name)
- [x] Edge 모델 (source, target)
- [x] Graph 모델 (nodes, edges)
- [x] 스캔 결과를 Graph로 변환
- [x] JSON 형태로 파일 출력

**확인**: `graph.json` 파일 생성되고 내용 맞는지 ✅

---

### v0.0.5 - Mermaid 출력 ✅
- [x] Graph → Mermaid flowchart 문법 변환
- [x] `.md` 파일로 출력
- [x] 노드가 많으면 읽기 어려우니 파일명만 표시
- [x] **subgraph로 그룹핑 지원** (추가)

**확인**: GitHub에 올리거나 Mermaid Live Editor에서 렌더링 되는지 ✅

---

### v0.0.6 - 설정 파일 (fdg.yaml) ✅
- [x] fdg.yaml 파싱
- [x] 정규식 패턴으로 그룹 규칙 정의
- [x] 캡처 그룹 ($1, $2) 지원
- [x] 기본 규칙 제공 (features/, core/, shared/)
- [x] exclude 패턴 지원

**확인**: fdg.yaml 수정하면 그룹핑 바뀌는지 ✅

---

### v0.0.7 - HTML 출력 ✅
- [x] Mermaid.js CDN 임베드한 HTML 템플릿
- [x] Graph 데이터 삽입
- [x] `.html` 파일로 출력
- [x] 브라우저에서 바로 열어서 확인 가능

**확인**: 브라우저에서 그래프 보이는지 ✅

---

### v0.0.8 - CLI 옵션
- [ ] `args` 패키지로 옵션 파싱
- [ ] `-o, --output`: 출력 파일 경로
- [ ] `-f, --format`: json | mermaid | html
- [ ] `-e, --exclude`: 제외 패턴 (복수 가능)
- [ ] `--help`: 도움말
- [ ] 기본값: format=html, output=graph.html

**확인**: 옵션 바꿔가며 실행해서 동작하는지

---

### v0.1.0 - 정리 및 배포 준비
- [ ] 코드 정리, 에러 처리 보완
- [ ] README.md 작성
- [ ] 기본 테스트 추가
- [ ] `dart pub publish --dry-run` 통과
- [ ] pub.dev 배포

**확인**: `dart pub global activate` 해서 `fdg` 명령어 동작하는지

---

## 후순위 (v0.1.0 이후)

- 엔티티 타입 자동 분류 (Widget, Service 등)
- 순환 의존성 탐지
- D3.js 인터랙티브 그래프
- Git diff 연동
- 특정 파일 기준 필터링 (이 파일이 의존하는 것들만 / 이 파일을 의존하는 것들만)

---

## 기술 스택

| 항목 | 선택 |
|------|------|
| Import 파싱 | 정규식 (문제 생기면 analyzer로 전환) |
| CLI | args |
| 경로 처리 | path |
| 설정 파일 | fdg.yaml (간단한 정규식 파싱) |

---

## 파일 구조

```
lib/src/
  file_scanner.dart      # 파일 스캔
  import_parser.dart     # import 파싱
  pubspec_reader.dart    # 패키지명 읽기
  models.dart            # Node, Edge, Graph
  graph_builder.dart     # Graph 빌드
  mermaid_generator.dart # Mermaid 출력
  html_generator.dart    # HTML 출력
  config_reader.dart     # fdg.yaml 파싱
bin/
  fdg.dart               # CLI 진입점
```

---

## 참고

- [lakos](https://pub.dev/packages/lakos) - 유사 도구
- [Mermaid](https://mermaid.js.org/) - 그래프 문법

---

*v4 작성일: 2026-02-04*
