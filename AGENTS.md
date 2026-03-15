# AGENTS.md (iOS/Swift)

  ## 적용 범위
  - 이 규칙은 현재 저장소 루트와 모든 하위 디렉터리에 적용됩니다.

  ## 기술 스택
  - Swift 6, iOS 17+, SwiftUI, async/await를 기본으로 사용합니다.

  ## 아키텍처
  - 클린 아키텍처 + MVVM 패턴을 사용합니다.
    - Data Layer: DataSource, Repository Implement, DTO, PersistantStorage
    - Domain Layer: Entity, UseCase, Repository Interface
    - Presentation Layer: View, ViewModel

  ## 코드 규칙
  - 프로덕션 코드에서 강제 언래핑(`!`)을 사용하지 않습니다.
  - 새 async 관련 타입은 가능한 경우 `Sendable`을 준수합니다.
  - UI 문자열은 `LocalizedStringResource`를 사용합니다.
  - ViewmModel은 ObservableObject를 채택한다.
  - 비즈니스 로직은 ViewModel/Domain Layer에만 둡니다.

  ## 테스트
  - ViewModel 변경 시 XCTest를 반드시 추가/수정합니다.
  - 버그 수정 시 재발 방지(회귀) 테스트를 반드시 포함합니다.

  ## 안전 규칙
  - 필요하지 않으면 `.pbxproj` 파일을 수동 편집하지 않습니다.
  - 명시적 요청 없이는 파괴적 git 명령을 실행하지 않습니다.
