import XCTest
@testable import MyStockManageApp

@MainActor
final class EarningsRevenueDetailsViewModelTests: XCTestCase {
    func testInitialStateUsesCurrentYearAndShowsAllCategories() {
        let sut = EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026
        )

        XCTAssertEqual(sut.yearCategories, [2028, 2027, 2026, 2025, 2024])
        XCTAssertEqual(sut.selectedYear, 2026)
        XCTAssertTrue(sut.isCurrentFiscalYearSelected)
        XCTAssertEqual(sut.quarterItems.map(\.quarterTitle), ["Q4 2026", "Q3 2026", "Q2 2026", "Q1 2026"])
    }

    func testSelectingDifferentYearUpdatesQuarterItemsAndCurrentFiscalFlag() {
        let sut = EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026
        )

        sut.didSelectYear(2028)

        XCTAssertEqual(sut.selectedYear, 2028)
        XCTAssertFalse(sut.isCurrentFiscalYearSelected)
        XCTAssertEqual(sut.quarterItems.map(\.quarterTitle), ["Q4 2028", "Q3 2028", "Q2 2028", "Q1 2028"])
    }

    func testReportedQuarterShowsRevenueAndEpsPerformanceSeparately() {
        let sut = EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026
        )

        let quarter = sut.quarterItems[2]

        XCTAssertEqual(quarter.state, .beat)
        XCTAssertEqual(quarter.revenuePerformanceText, "+2.5% beat")
        XCTAssertEqual(quarter.epsPerformanceText, "+2.1% beat")
    }

    func testPartialMissStateIsUsedWhenOnlyOneMetricBeatsEstimate() {
        let sut = EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026
        )

        sut.didSelectYear(2025)

        let quarter = sut.quarterItems[2]

        XCTAssertEqual(quarter.state, .partialMiss)
        XCTAssertEqual(quarter.revenuePerformanceText, "+0.9% beat")
        XCTAssertEqual(quarter.epsPerformanceText, "-1.4% miss")
    }

    func testBackButtonInvokesDismissAction() {
        var dismissCallCount = 0
        let sut = EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026,
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
