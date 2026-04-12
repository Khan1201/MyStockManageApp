import XCTest
@testable import MyStockManageApp

@MainActor
final class EarningsRevenueDetailsViewModelTests: XCTestCase {
    func testLoadUsesCurrentYearAndShowsAllCategories() async {
        let sut = makeSUT()

        await sut.loadEarningsRevenue()

        XCTAssertEqual(sut.yearCategories, [2028, 2027, 2026, 2025])
        XCTAssertEqual(sut.selectedYear, 2026)
        XCTAssertTrue(sut.isCurrentFiscalYearSelected)
        XCTAssertEqual(sut.quarterItems.map(\.quarterTitle), ["Q4 2026", "Q3 2026", "Q2 2026", "Q1 2026"])
    }

    func testSelectingDifferentYearUpdatesQuarterItemsAndCurrentFiscalFlag() async {
        let sut = makeSUT()
        await sut.loadEarningsRevenue()

        sut.didSelectYear(2028)

        XCTAssertEqual(sut.selectedYear, 2028)
        XCTAssertFalse(sut.isCurrentFiscalYearSelected)
        XCTAssertEqual(sut.quarterItems.map(\.quarterTitle), ["Q4 2028", "Q3 2028", "Q2 2028", "Q1 2028"])
    }

    func testReportedQuarterShowsRevenueAndEpsPerformanceSeparately() async {
        let sut = makeSUT()
        await sut.loadEarningsRevenue()

        let quarter = sut.quarterItems[2]

        XCTAssertEqual(quarter.state, .beat)
        XCTAssertEqual(quarter.revenuePerformanceText, "+2.5% beat")
        XCTAssertEqual(quarter.epsPerformanceText, "+2.1% beat")
    }

    func testPartialMissStateIsUsedWhenOnlyOneMetricBeatsEstimate() async {
        let sut = makeSUT()
        await sut.loadEarningsRevenue()

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

    private func makeSUT() -> EarningsRevenueDetailsViewModel {
        EarningsRevenueDetailsViewModel(
            stock: makeAppleStock(),
            currentYear: 2026,
            fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase(
                operation: { _ in
                    [
                        EarningsYearRecord(
                            year: 2028,
                            quarterItems: [
                                EarningsQuarterRecord(id: "2028_q4", quarterTitle: "Q4 2028", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$16.90B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.98", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2028_q3", quarterTitle: "Q3 2028", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$16.35B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.92", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2028_q2", quarterTitle: "Q2 2028", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$15.80B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.86", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2028_q1", quarterTitle: "Q1 2028", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$15.10B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.79", epsEstimateText: nil, epsPerformancePercent: nil)
                            ]
                        ),
                        EarningsYearRecord(
                            year: 2027,
                            quarterItems: [
                                EarningsQuarterRecord(id: "2027_q4", quarterTitle: "Q4 2027", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$15.60B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.86", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2027_q3", quarterTitle: "Q3 2027", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$14.90B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.78", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2027_q2", quarterTitle: "Q2 2027", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$14.40B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.71", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2027_q1", quarterTitle: "Q1 2027", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$13.95B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.67", epsEstimateText: nil, epsPerformancePercent: nil)
                            ]
                        ),
                        EarningsYearRecord(
                            year: 2026,
                            quarterItems: [
                                EarningsQuarterRecord(id: "2026_q4", quarterTitle: "Q4 2026", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$13.85B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.62", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2026_q3", quarterTitle: "Q3 2026", trailingStatusText: "ESTIMATED", state: .projected, revenueValueText: "$13.10B", revenueEstimateText: nil, revenuePerformancePercent: nil, epsValueText: "$1.55", epsEstimateText: nil, epsPerformancePercent: nil),
                                EarningsQuarterRecord(id: "2026_q2", quarterTitle: "Q2 2026", trailingStatusText: "REPORTED JUL 24", state: .beat, revenueValueText: "$12.4B", revenueEstimateText: "Est. $12.1B", revenuePerformancePercent: 2.5, epsValueText: "$1.45", epsEstimateText: "Est. $1.42", epsPerformancePercent: 2.1),
                                EarningsQuarterRecord(id: "2026_q1", quarterTitle: "Q1 2026", trailingStatusText: "REPORTED APR 20", state: .miss, revenueValueText: "$11.8B", revenueEstimateText: "Est. $11.9B", revenuePerformancePercent: -0.8, epsValueText: "$1.38", epsEstimateText: "Est. $1.40", epsPerformancePercent: -1.4)
                            ]
                        ),
                        EarningsYearRecord(
                            year: 2025,
                            quarterItems: [
                                EarningsQuarterRecord(id: "2025_q4", quarterTitle: "Q4 2025", trailingStatusText: "REPORTED OCT 28", state: .beat, revenueValueText: "$12.8B", revenueEstimateText: "Est. $12.4B", revenuePerformancePercent: 3.2, epsValueText: "$1.49", epsEstimateText: "Est. $1.44", epsPerformancePercent: 3.5),
                                EarningsQuarterRecord(id: "2025_q3", quarterTitle: "Q3 2025", trailingStatusText: "REPORTED JUL 25", state: .beat, revenueValueText: "$12.1B", revenueEstimateText: "Est. $12.0B", revenuePerformancePercent: 0.8, epsValueText: "$1.41", epsEstimateText: "Est. $1.39", epsPerformancePercent: 1.4),
                                EarningsQuarterRecord(id: "2025_q2", quarterTitle: "Q2 2025", trailingStatusText: "REPORTED APR 24", state: .partialMiss, revenueValueText: "$11.7B", revenueEstimateText: "Est. $11.6B", revenuePerformancePercent: 0.9, epsValueText: "$1.36", epsEstimateText: "Est. $1.38", epsPerformancePercent: -1.4),
                                EarningsQuarterRecord(id: "2025_q1", quarterTitle: "Q1 2025", trailingStatusText: "REPORTED JAN 23", state: .miss, revenueValueText: "$11.2B", revenueEstimateText: "Est. $11.3B", revenuePerformancePercent: -0.8, epsValueText: "$1.30", epsEstimateText: "Est. $1.31", epsPerformancePercent: -0.8)
                            ]
                        )
                    ]
                }
            )
        )
    }

    private func makeAppleStock() -> PortfolioStock {
        .init(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: 1.24,
            brand: .apple
        )
    }
}
