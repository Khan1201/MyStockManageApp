import XCTest
@testable import MyStockManageApp

@MainActor
final class StockDetailsViewModelTests: XCTestCase {
    func testPriceChangeTextUsesSignedCurrencyAndPercentMagnitude() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        XCTAssertEqual(sut.priceText, "$189.43")
        XCTAssertEqual(sut.priceChangeText, "+$2.32 (1.24%)")
    }

    func testDidTapAddButtonTogglesWatchlistState() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        XCTAssertEqual(sut.addButtonSymbolName, "plus")

        sut.didTapAddButton()
        XCTAssertEqual(sut.addButtonSymbolName, "checkmark")

        sut.didTapAddButton()
        XCTAssertEqual(sut.addButtonSymbolName, "plus")
    }

    func testDidTapCloseButtonInvokesDismissAction() {
        var dismissCallCount = 0
        let sut = StockDetailsViewModel(
            stock: makeAppleStock(),
            dismissAction: {
                dismissCallCount += 1
            }
        )

        sut.didTapCloseButton()

        XCTAssertEqual(dismissCallCount, 1)
    }

    func testDidTapAnalystForecastsSeeAllPresentsFullScreenCover() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        XCTAssertFalse(sut.isPresentingAnalystForecasts)

        sut.didTapAnalystForecastsSeeAll()

        XCTAssertTrue(sut.isPresentingAnalystForecasts)

        sut.didDismissAnalystForecasts()

        XCTAssertFalse(sut.isPresentingAnalystForecasts)
    }

    func testAppleContentMatchesExpectedSectionData() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        XCTAssertEqual(sut.analystForecasts.map(\.count), [12, 10, 6, 2, 0])
        XCTAssertEqual(sut.sentimentItems.map(\.count), [12, 4])
        XCTAssertEqual(sut.earningsEstimateRows.map(\.yearText), ["2024", "2025", "2026", "2027", "2028"])
    }

    private func makeAppleStock() -> PortfolioStock {
        .init(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: 1.24,
            logoStyle: .apple
        )
    }
}
