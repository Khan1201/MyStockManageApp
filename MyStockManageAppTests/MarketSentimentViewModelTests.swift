import XCTest
@testable import MyStockManageApp

@MainActor
final class MarketSentimentViewModelTests: XCTestCase {
    func testDefaultFilterShowsAllSectionsAndItems() {
        let sut = MarketSentimentViewModel(stock: makeNVDAStock())

        XCTAssertEqual(sut.selectedFilter, .all)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "yesterday", "archive"])
        XCTAssertEqual(sut.filteredSections.flatMap(\.items).count, 5)
    }

    func testDidSelectBullishFilterShowsOnlyBullishItems() {
        let sut = MarketSentimentViewModel(stock: makeNVDAStock())

        sut.didSelectFilter(.bullish)

        XCTAssertEqual(sut.selectedFilter, .bullish)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "yesterday", "archive"])
        XCTAssertEqual(
            sut.filteredSections.flatMap(\.items).map(\.signal),
            [.bullish, .bullish, .bullish]
        )
    }

    func testDidSelectBearishFilterDropsEmptySections() {
        let sut = MarketSentimentViewModel(stock: makeNVDAStock())

        sut.didSelectFilter(.bearish)

        XCTAssertEqual(sut.selectedFilter, .bearish)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "archive"])
        XCTAssertEqual(
            sut.filteredSections.flatMap(\.items).map(\.signal),
            [.bearish, .bearish]
        )
    }

    func testDidTapBackButtonInvokesDismissAction() {
        var dismissCallCount = 0
        let sut = MarketSentimentViewModel(
            stock: makeNVDAStock(),
            dismissAction: {
                dismissCallCount += 1
            }
        )

        sut.didTapBackButton()

        XCTAssertEqual(dismissCallCount, 1)
    }

    private func makeNVDAStock() -> PortfolioStock {
        .init(
            symbol: "NVDA",
            companyName: "NVIDIA Corporation",
            price: 924.79,
            changePercent: 2.38,
            logoStyle: .nvidia
        )
    }
}
