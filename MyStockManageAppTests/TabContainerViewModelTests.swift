import XCTest
@testable import MyStockManageApp

@MainActor
final class TabContainerViewModelTests: XCTestCase {
    func testSelectedTabDefaultsToHome() {
        let sut = TabContainerViewModel()

        XCTAssertEqual(sut.selectedTab, .home)
    }

    func testDidSelectTabUpdatesSelectedTab() {
        let sut = TabContainerViewModel()

        sut.didSelectTab(.quotes)

        XCTAssertEqual(sut.selectedTab, .quotes)
    }
}
