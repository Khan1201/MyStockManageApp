import XCTest
@testable import MyStockManageApp

@MainActor
final class StockDetailsViewModelTests: XCTestCase {
    func testLoadStockInsightsMapsDomainContentIntoPresentationRows() async {
        let sut = StockDetailsViewModel(
            stock: makeAppleStock(),
            fetchStockInsightsUseCase: FetchStockInsightsUseCase(
                operation: { _ in
                    StockInsights(
                        forecastSummary: [
                            ForecastSummaryMetric(id: "strong_buy", recommendation: .strongBuy, count: 12),
                            ForecastSummaryMetric(id: "buy", recommendation: .buy, count: 10)
                        ],
                        sentimentSummary: [
                            SentimentSummaryMetric(id: "bullish", signal: .bullish, count: 12),
                            SentimentSummaryMetric(id: "bearish", signal: .bearish, count: 4)
                        ],
                        earningsEstimates: [
                            StockEstimateSnapshot(
                                id: "2024_actual",
                                year: 2024,
                                stage: .actual,
                                revenueText: "$383.3B",
                                revenueDeltaText: "-2.1%",
                                revenueDeltaPercent: -2.1,
                                epsText: "$6.13",
                                epsDeltaText: "-1.2%",
                                epsDeltaPercent: -1.2
                            )
                        ]
                    )
                }
            )
        )

        await sut.loadStockInsights()

        XCTAssertEqual(sut.analystForecasts.map(\.count), [12, 10])
        XCTAssertEqual(sut.sentimentItems.map(\.count), [12, 4])
        XCTAssertEqual(sut.earningsEstimateRows.map(\.yearText), ["2024"])
    }

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

    func testMarketSentimentViewModelDismissActionResetsPresentationState() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        sut.didTapMarketSentimentSeeAll()
        sut.marketSentimentViewModel.didTapBackButton()

        XCTAssertFalse(sut.isPresentingMarketSentiment)
    }

    func testEarningsRevenueDetailsViewModelDismissActionResetsPresentationState() {
        let sut = StockDetailsViewModel(stock: makeAppleStock())

        sut.didTapEarningsEstimatesSeeAll()
        sut.earningsRevenueDetailsViewModel.didTapBackButton()

        XCTAssertFalse(sut.isPresentingEarningsRevenueDetails)
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
