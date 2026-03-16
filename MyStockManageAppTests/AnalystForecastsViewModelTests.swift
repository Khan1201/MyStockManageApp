import XCTest
@testable import MyStockManageApp

@MainActor
final class AnalystForecastsViewModelTests: XCTestCase {
    func testAppleContentMatchesExpectedOverviewAndForecastRows() {
        let sut = AnalystForecastsViewModel(stock: makeAppleStock())

        XCTAssertEqual(sut.overviewItems.map(\.valueText), ["$202.40", "Buy", "24"])
        XCTAssertEqual(sut.forecasts.map(\.firmName), [
            "Goldman Sachs",
            "Barclays",
            "Morgan Stanley",
            "J.P. Morgan",
            "Bank of America",
            "UBS"
        ])
        XCTAssertEqual(sut.forecasts.first?.priceTargetText, "$210.00")
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
