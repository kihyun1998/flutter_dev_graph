# flutter_dev_graph 프로젝트 계획서

## 1. 개요

### 1.1 프로젝트 정보

| 항목 | 내용 |
|------|------|
| 패키지명 | `flutter_dev_graph` |
| CLI 명령어 | `fdg` |
| 타입 | Dart CLI 도구 (pub global activate 지원) |
| 배포 | pub.dev |
| 라이선스 | MIT |

### 1.2 목적

Flutter/Dart 프로젝트의 코드 구조를 분석하여 의존성 그래프를 시각화하고, 변경 사항의 영향도를 파악할 수 있는 개발 도구

### 1.3 핵심 가치

- **가시성**: 프로젝트 구조를 한눈에 파악
- **품질**: 순환 의존성, 레이어 위반 등 문제 조기 발견
- **생산성**: 변경 영향도 분석으로 안전한 리팩토링 지원

---

## 2. 주요 기능

### 2.1 코드 분석 기능

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| Import/Export 파싱 | 파일 간 의존 관계 추출 | P0 |
| 엔티티 자동 분류 | Widget, Model, Service, Repository, Provider 등 타입 자동 인식 | P0 |
| 클래스 정보 추출 | 파일 내 클래스명, 상속 관계, 어노테이션 파싱 | P0 |
| 순환 의존성 탐지 | Circular dependency 발견 및 경고 | P1 |
| 미사용 파일 탐지 | 어디서도 import되지 않는 파일 목록 | P1 |
| Riverpod Provider 분석 | Provider 간 의존 관계 특화 분석 | P2 |
| 아키텍처 규칙 검증 | 레이어 간 의존 규칙 위반 감지 | P2 |

### 2.2 출력 포맷

| 포맷 | 확장자 | 설명 | 외부 도구 필요 | 우선순위 |
|------|--------|------|----------------|----------|
| JSON | `.json` | Raw 데이터, 다른 도구 연동용 | 없음 | P0 |
| Mermaid | `.md` | GitHub/GitLab에서 바로 렌더링 | 없음 | P0 |
| HTML (Mermaid) | `.html` | 브라우저에서 바로 열기 (정적) | 없음 | P0 |
| HTML (D3.js) | `.html` | 인터랙티브 그래프 (드래그, 줌, 필터) | 없음 | P1 |
| D2 | `.d2` | D2 소스 파일 | 없음 | P1 |
| D2 → SVG | `.svg` | D2로 렌더링된 이미지 | d2 CLI | P1 |
| DOT | `.dot` | Graphviz 소스 파일 | 없음 | P1 |
| DOT → SVG | `.svg` | Graphviz로 렌더링된 이미지 | graphviz CLI | P1 |
| PNG | `.png` | 이미지 파일 | d2 또는 graphviz | P2 |

### 2.3 변경 분석 기능

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| Git diff 연동 | 특정 커밋/브랜치 대비 변경 파일 추출 | P1 |
| 영향도 분석 | 변경된 파일이 영향 미치는 파일들 역추적 | P1 |
| 변경 요약 리포트 | Markdown/HTML 형태 리포트 생성 | P1 |
| Breaking change 감지 | Public API 시그니처 변경 탐지 | P2 |

---

## 3. CLI 인터페이스

### 3.1 명령어 구조

```
fdg <command> [options] [path]
```

### 3.2 Commands

#### `fdg analyze` - 의존성 분석 및 그래프 생성

| 옵션 | 단축 | 설명 | 기본값 |
|------|------|------|--------|
| `--output` | `-o` | 출력 파일 경로 | `dependency_graph.html` |
| `--format` | `-f` | 출력 포맷 | `html` |
| `--exclude` | `-e` | 제외 패턴 (복수 가능) | `.g.dart`, `.freezed.dart` |
| `--check-cycles` | | 순환 의존성 체크 | `true` |
| `--filter-type` | | 특정 타입만 포함 | 전체 |
| `--verbose` | `-v` | 상세 로그 출력 | `false` |

**사용 예시**:
```bash
fdg analyze ./my_project -o graph.html
fdg analyze . --format json -o deps.json
fdg analyze . --format html-d3 -o interactive.html
fdg analyze . --format mermaid -o README_GRAPH.md
fdg analyze . --exclude "**_test.dart" --exclude "**/generated/**"
```

#### `fdg diff` - 변경 영향도 분석

| 옵션 | 단축 | 설명 | 기본값 |
|------|------|------|--------|
| `--since` | `-s` | 비교 대상 Git ref | `HEAD~1` |
| `--output` | `-o` | 출력 파일 경로 | stdout |
| `--format` | `-f` | 리포트 포맷 (json, md, html) | `md` |

**사용 예시**:
```bash
fdg diff --since HEAD~5
fdg diff --since main -o changes.md
fdg diff --since v1.0.0 --format html -o impact_report.html
```

#### `fdg init` - 설정 파일 생성

프로젝트 루트에 `fdg.yaml` 설정 파일 생성

**사용 예시**:
```bash
fdg init
```

#### `fdg check` - 규칙 검사만 수행

| 옵션 | 설명 |
|------|------|
| `--cycles` | 순환 의존성만 검사 |
| `--unused` | 미사용 파일만 검사 |
| `--architecture` | 아키텍처 규칙만 검사 |

**사용 예시**:
```bash
fdg check --cycles
fdg check --architecture
```

---

## 4. 엔티티 분류 체계

### 4.1 자동 분류 기준

| 엔티티 타입 | 분류 기준 |
|-------------|-----------|
| **Widget** | `StatelessWidget`, `StatefulWidget`, `HookWidget`, `ConsumerWidget` 상속 |
| **Screen/Page** | Widget 중 이름에 `Screen`, `Page` 포함 |
| **Model** | 이름이 `Model`, `Entity`로 끝나거나 `/models/`, `/entities/` 경로 |
| **Service** | 이름이 `Service`로 끝나거나 `/services/` 경로 |
| **Repository** | 이름이 `Repository`로 끝나거나 `/repositories/` 경로 |
| **Provider** | `@riverpod` 어노테이션 또는 `/providers/` 경로 |
| **Controller** | 이름이 `Controller`, `Bloc`, `Cubit`으로 끝남 |
| **UseCase** | 이름이 `UseCase`로 끝나거나 `/usecases/` 경로 |
| **Utility** | `/utils/`, `/helpers/`, `/extensions/` 경로 |
| **Unknown** | 위 조건에 해당하지 않음 |

### 4.2 커스텀 분류 규칙

`fdg.yaml`에서 프로젝트별 분류 규칙 정의 가능

---

## 5. 설정 파일 (fdg.yaml)

### 5.1 설정 항목

| 섹션 | 항목 | 설명 |
|------|------|------|
| `analyzer` | `exclude` | 분석 제외 패턴 목록 |
| | `include_tests` | 테스트 파일 포함 여부 |
| `output` | `format` | 기본 출력 포맷 |
| | `path` | 기본 출력 경로 |
| `classification` | `patterns` | 커스텀 엔티티 분류 규칙 |
| `architecture` | `layers` | 레이어 정의 |
| | `rules` | 레이어 간 의존 규칙 |

---

## 6. 출력물 상세

### 6.1 JSON 출력 구조

| 필드 | 설명 |
|------|------|
| `projectName` | 프로젝트명 (pubspec.yaml에서 추출) |
| `analyzedAt` | 분석 시각 |
| `summary` | 요약 (총 노드 수, 엣지 수, 타입별 카운트) |
| `nodes[]` | 노드 목록 (id, 파일경로, 이름, 타입, 클래스 목록, 라인 수) |
| `edges[]` | 엣지 목록 (source, target, 의존성 타입, alias, show/hide) |
| `cycles[]` | 순환 의존성 목록 (있는 경우) |
| `unused[]` | 미사용 파일 목록 (있는 경우) |

### 6.2 HTML (D3.js Interactive) 기능

| 기능 | 설명 |
|------|------|
| Force-directed 레이아웃 | 노드 자동 배치 |
| 드래그 | 노드 위치 조정 |
| 줌/패닝 | 마우스 휠, 드래그로 뷰 조정 |
| 호버 툴팁 | 노드 상세 정보 표시 |
| 타입별 필터링 | 특정 엔티티 타입만 표시 |
| 검색 | 파일/클래스명 검색 |
| 노드 크기 | 라인 수에 비례 |
| 색상 구분 | 엔티티 타입별 색상 |

### 6.3 Mermaid 출력 특징

| 특징 | 설명 |
|------|------|
| Subgraph | 엔티티 타입별 그룹핑 |
| 노드 모양 | 타입별 다른 모양 (사각형, 원형 등) |
| 엣지 스타일 | import는 실선, export는 점선 |
| GitHub 호환 | README.md에 삽입 시 바로 렌더링 |

---

## 7. 기술 스택

### 7.1 Dependencies

| 패키지 | 용도 |
|--------|------|
| `analyzer` | Dart AST 파싱 |
| `args` | CLI 인자 파싱 |
| `path` | 파일 경로 처리 |
| `glob` | 파일 패턴 매칭 |
| `yaml` | 설정 파일 파싱 |
| `collection` | 컬렉션 유틸리티 |

### 7.2 외부 도구 (선택적)

| 도구 | 용도 | 필수 여부 |
|------|------|-----------|
| `d2` | D2 → SVG/PNG 변환 | 선택 |
| `graphviz` | DOT → SVG/PNG 변환 | 선택 |
| `git` | 변경 분석 | diff 명령어 사용 시 필수 |

---

## 8. 디렉토리 구조

```
flutter_dev_graph/
├── bin/
│   └── fdg.dart                  # CLI 진입점
├── lib/
│   ├── flutter_dev_graph.dart    # 라이브러리 export
│   └── src/
│       ├── cli/                  # CLI 관련
│       │   ├── cli_runner.dart
│       │   └── commands/
│       │       ├── analyze_command.dart
│       │       ├── diff_command.dart
│       │       ├── init_command.dart
│       │       └── check_command.dart
│       ├── analyzer/             # 코드 분석
│       │   ├── project_analyzer.dart
│       │   ├── dart_file_parser.dart
│       │   ├── import_resolver.dart
│       │   └── entity_classifier.dart
│       ├── graph/                # 그래프 자료구조
│       │   ├── dependency_graph.dart
│       │   ├── node.dart
│       │   ├── edge.dart
│       │   └── algorithms/
│       │       ├── cycle_detector.dart
│       │       ├── impact_analyzer.dart
│       │       └── unused_detector.dart
│       ├── differ/               # Git 변경 분석
│       │   ├── git_differ.dart
│       │   └── impact_calculator.dart
│       ├── exporters/            # 출력 포맷
│       │   ├── exporter.dart
│       │   ├── json_exporter.dart
│       │   ├── mermaid_exporter.dart
│       │   ├── html_mermaid_exporter.dart
│       │   ├── html_d3_exporter.dart
│       │   ├── d2_exporter.dart
│       │   └── dot_exporter.dart
│       ├── config/               # 설정 관리
│       │   └── config_loader.dart
│       └── models/               # 데이터 모델
│           ├── entity_type.dart
│           └── analysis_result.dart
├── templates/                    # HTML 템플릿
│   ├── html_mermaid.html
│   └── html_d3.html
├── test/                         # 테스트
├── example/                      # 예제
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## 9. 개발 로드맵

### Phase 0: 프로젝트 초기화 (Day 1)

- [ ] `dart create -t package flutter_dev_graph`
- [ ] pubspec.yaml 설정
- [ ] 디렉토리 구조 생성
- [ ] 기본 모델 정의

### Phase 1: 코어 분석 엔진 (Week 1-2)

- [ ] Dart AST 파싱 구현
- [ ] Import/Export 추출
- [ ] 엔티티 자동 분류
- [ ] 그래프 자료구조 구현
- [ ] JSON Exporter 구현
- [ ] Mermaid Exporter 구현
- [ ] `fdg analyze` 명령어 구현
- [ ] **v0.1.0 배포**

### Phase 2: HTML 시각화 (Week 3-4)

- [ ] HTML (Mermaid embed) Exporter
- [ ] HTML (D3.js interactive) Exporter
- [ ] 순환 의존성 탐지
- [ ] 미사용 파일 탐지
- [ ] `fdg check` 명령어 구현
- [ ] **v0.2.0 배포**

### Phase 3: 외부 포맷 지원 (Week 5)

- [ ] D2 Exporter
- [ ] DOT/Graphviz Exporter
- [ ] SVG/PNG 렌더링 (외부 CLI 호출)
- [ ] **v0.3.0 배포**

### Phase 4: 변경 분석 (Week 6-7)

- [ ] Git diff 연동
- [ ] 영향도 분석 알고리즘
- [ ] 변경 리포트 생성
- [ ] `fdg diff` 명령어 구현
- [ ] **v0.4.0 배포**

### Phase 5: 고급 기능 (Week 8+)

- [ ] fdg.yaml 설정 파일 지원
- [ ] `fdg init` 명령어
- [ ] 커스텀 분류 규칙
- [ ] 아키텍처 규칙 검증
- [ ] Riverpod Provider 특화 분석
- [ ] **v0.5.0 배포**

---

## 10. 배포 체크리스트

### pub.dev 배포 전 확인사항

- [ ] pubspec.yaml
  - [ ] name, version, description 확인
  - [ ] description 60-180자
  - [ ] repository URL
  - [ ] homepage URL
  - [ ] environment sdk 버전
  - [ ] executables 섹션 (fdg: fdg)

- [ ] 문서
  - [ ] README.md (설치, 사용법, 예시, 스크린샷)
  - [ ] CHANGELOG.md
  - [ ] LICENSE (MIT)
  - [ ] example/ 폴더

- [ ] 품질
  - [ ] `dart analyze` 통과
  - [ ] `dart test` 통과
  - [ ] `dart pub publish --dry-run` 통과

### 배포 명령어

```bash
dart pub publish
```

### 사용자 설치

```bash
dart pub global activate flutter_dev_graph
```

---

## 11. 향후 확장 계획

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| VS Code Extension | 에디터 내 그래프 뷰어 | 낮음 |
| Watch 모드 | 파일 변경 시 자동 갱신 | 낮음 |
| CI/CD 통합 | GitHub Actions에서 자동 생성 | 중간 |
| 메트릭스 | 복잡도, 결합도 점수 | 중간 |
| 비교 기능 | 두 시점 그래프 비교 | 낮음 |

---

## 12. 참고 자료

### 유사 도구

- [lakos](https://pub.dev/packages/lakos) - Dart 의존성 시각화
- [pubviz](https://pub.dev/packages/pubviz) - 패키지 의존성 시각화
- [dependency_validator](https://pub.dev/packages/dependency_validator) - 의존성 검증

### 다이어그램 포맷

- [Mermaid](https://mermaid.js.org/) - 텍스트 기반 다이어그램
- [D2](https://d2lang.com/) - 선언적 다이어그램 언어
- [Graphviz](https://graphviz.org/) - 그래프 시각화 도구

---

*문서 작성일: 2025-01-31*
*버전: 1.0*