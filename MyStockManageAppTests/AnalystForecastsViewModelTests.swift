import XCTest
@testable import MyStockManageApp

@MainActor
final class AnalystForecastsViewModelTests: XCTestCase {
    func testLoadAnalystForecastsMapsOverviewAndForecastRows() async {
        let sut = AnalystForecastsViewModel(
            stock: makeAppleStock(),
            fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase(
                operation: { _ in
                    AnalystForecastsContent(
                        overview: AnalystForecastOverview(
                            averageTarget: 202.4,
                            consensus: .buy,
                            analystsCount: 24
                        ),
                        forecasts: [
                            AnalystForecastRecord(
                                id: "goldman_sachs",
                                firmName: "Goldman Sachs",
                                analystName: "Jane Doe",
                                rating: .strongBuy,
                                score: 4.8,
                                dateText: "26/03/15",
                                priceTarget: 210
                            ),
                            AnalystForecastRecord(
                                id: "ubs",
                                firmName: "UBS",
                                analystName: "Sarah Miller",
                                rating: .sell,
                                score: 2.1,
                                dateText: "26/03/05",
                                priceTarget: 175
                            )
                        ]
                    )
                }
            )
        )

        await sut.loadAnalystForecasts()

        XCTAssertEqual(sut.overviewItems.map(\.valueText), ["$202.40", "Buy", "24"])
        XCTAssertEqual(sut.forecasts.map(\.firmName), ["Goldman Sachs", "UBS"])
        XCTAssertEqual(sut.forecasts.first?.priceTargetText, "$210.00")
        XCTAssertEqual(sut.forecasts.first?.trend, .upward)
        XCTAssertEqual(sut.forecasts.last?.trend, .downward)
    }

    func testDidTapBackButtonInvokesDismissAction() {
        var dismissCallCount = 0
        let sut = AnalystForecastsViewModel(
            stock: makeAppleStock(),
            dismissAction: {
                dismissCallCount += 1
            }
        )

        sut.didTapBackButton()

        XCTAssertEqual(dismissCallCount, 1)
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
