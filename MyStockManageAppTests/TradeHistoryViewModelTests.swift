import XCTest
@testable import MyStockManageApp

@MainActor
final class TradeHistoryViewModelTests: XCTestCase {
    func testDisplayedSectionsGroupsTransactionsByMonthInDescendingOrder() {
        let sut = TradeHistoryViewModel(transactions: makeTransactions())

        XCTAssertEqual(sut.displayedSections.map(\.title), ["MARCH 2026", "FEBRUARY 2026"])
        XCTAssertEqual(sut.displayedSections.first?.transactions.map(\.symbol), ["TSLA", "AAPL", "NVDA"])
        XCTAssertEqual(sut.displayedSections.last?.transactions.map(\.symbol), ["GOOGL", "MSFT"])
    }

    func testDidSelectFilterUpdatesSelectedFilterAndVisibleTransactions() {
        let sut = TradeHistoryViewModel(transactions: makeTransactions())

        sut.didSelectFilter(.sell)

        XCTAssertEqual(sut.selectedFilter, .sell)
        XCTAssertEqual(sut.displayedSections.map(\.transactions).flatMap { $0 }.map(\.symbol), ["AAPL", "GOOGL"])
    }

    func testSummaryTextReflectsSelectedFilter() {
        let sut = TradeHistoryViewModel(transactions: makeTransactions())

        XCTAssertEqual(sut.summaryText, "2026: 3 Buys, 2 Sells")

        sut.didSelectFilter(.buy)
        XCTAssertEqual(sut.summaryText, "2026: 3 Buys")

        sut.didSelectFilter(.sell)
        XCTAssertEqual(sut.summaryText, "2026: 2 Sells")
    }

    private func makeTransactions() -> [TradeHistoryTransaction] {
        [
            TradeHistoryTransaction(symbol: "TSLA", tradedAt: makeDate(year: 2026, month: 3, day: 15), shareCount: 200, transactionType: .buy),
            TradeHistoryTransaction(symbol: "AAPL", tradedAt: makeDate(year: 2026, month: 3, day: 10), shareCount: 50, transactionType: .sell),
            TradeHistoryTransaction(symbol: "NVDA", tradedAt: makeDate(year: 2026, month: 3, day: 5), shareCount: 100, transactionType: .buy),
            TradeHistoryTransaction(symbol: "GOOGL", tradedAt: makeDate(year: 2026, month: 2, day: 28), shareCount: 30, transactionType: .sell),
            TradeHistoryTransaction(symbol: "MSFT", tradedAt: makeDate(year: 2026, month: 2, day: 15), shareCount: 80, transactionType: .buy)
        ]
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        )

        return calendar.date(from: components) ?? .distantPast
    }
}
