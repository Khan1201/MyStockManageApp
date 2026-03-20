import XCTest
@testable import MyStockManageApp

@MainActor
final class TradeHistoryViewModelTests: XCTestCase {
    func testLoadTradeHistoryGroupsTransactionsByMonthInDescendingOrder() async {
        let store = TradeHistoryStoreMock(trades: makeTradeRecords())
        let sut = makeSUT(store: store)

        await sut.loadTradeHistory()

        XCTAssertEqual(sut.displayedSections.map(\.title), ["MARCH 2026", "FEBRUARY 2026"])
        XCTAssertEqual(sut.displayedSections.first?.transactions.map(\.symbol), ["TSLA", "AAPL", "NVDA"])
        XCTAssertEqual(sut.displayedSections.last?.transactions.map(\.symbol), ["GOOGL", "MSFT"])
    }

    func testDidSelectFilterUpdatesSelectedFilterAndVisibleTransactions() async {
        let store = TradeHistoryStoreMock(trades: makeTradeRecords())
        let sut = makeSUT(store: store)
        await sut.loadTradeHistory()

        sut.didSelectFilter(.sell)

        XCTAssertEqual(sut.selectedFilter, .sell)
        XCTAssertEqual(sut.displayedSections.map(\.transactions).flatMap { $0 }.map(\.symbol), ["AAPL", "GOOGL"])
    }

    func testSummaryTextReflectsSelectedFilter() async {
        let store = TradeHistoryStoreMock(trades: makeTradeRecords())
        let sut = makeSUT(store: store)
        await sut.loadTradeHistory()

        XCTAssertEqual(sut.summaryText, "2026: 3 Buys, 2 Sells")

        sut.didSelectFilter(.buy)
        XCTAssertEqual(sut.summaryText, "2026: 3 Buys")

        sut.didSelectFilter(.sell)
        XCTAssertEqual(sut.summaryText, "2026: 2 Sells")
    }

    func testDidTapAddTradeButtonPresentsTradeEditor() {
        let sut = makeSUT(store: TradeHistoryStoreMock(trades: makeTradeRecords()))

        XCTAssertNil(sut.tradeEditorViewModel)

        sut.didTapAddTradeButton()

        XCTAssertNotNil(sut.tradeEditorViewModel)
    }

    func testDidDismissTradeEditorClearsPresentedEditor() {
        let sut = makeSUT(store: TradeHistoryStoreMock(trades: makeTradeRecords()))

        sut.didTapAddTradeButton()
        sut.didDismissTradeEditor()

        XCTAssertNil(sut.tradeEditorViewModel)
    }

    func testSavingTradeFromPresentedEditorPersistsTradeAndReloadsTransactions() async {
        let store = TradeHistoryStoreMock(trades: makeTradeRecords())
        let sut = makeSUT(store: store)
        await sut.loadTradeHistory()

        sut.didTapAddTradeButton()

        guard let editor = sut.tradeEditorViewModel else {
            XCTFail("Expected trade editor to be presented")
            return
        }

        editor.didUpdateSymbol("AMD")
        editor.didSelectTransactionType(.sell)
        editor.didChangeTradeDate(makeDate(year: 2026, month: 4, day: 1))
        editor.didChangeQuantityText("75")
        editor.didSelectStrategy(.themeBased)
        editor.didChangeTargetPriceText("250")
        editor.didChangeStopLossText("150")

        await editor.didTapSaveButton()

        XCTAssertNil(sut.tradeEditorViewModel)
        XCTAssertEqual(sut.displayedSections.map(\.title), ["APRIL 2026", "MARCH 2026", "FEBRUARY 2026"])
        XCTAssertEqual(sut.displayedSections.first?.transactions.first?.symbol, "AMD")
        XCTAssertEqual(sut.displayedSections.first?.transactions.first?.shareCount, 75)
        XCTAssertEqual(sut.displayedSections.first?.transactions.first?.targetPrice, 250)
        XCTAssertEqual(sut.displayedSections.first?.transactions.first?.stopLoss, 150)
        XCTAssertEqual(sut.summaryText, "2026: 3 Buys, 3 Sells")
    }

    private func makeSUT(store: TradeHistoryStoreMock) -> TradeHistoryViewModel {
        TradeHistoryViewModel(
            fetchTradeHistoryUseCase: FetchTradeHistoryUseCase(
                operation: {
                    await store.fetchTrades()
                }
            ),
            saveTradeUseCase: SaveTradeUseCase(
                operation: { trade in
                    await store.saveTrade(trade)
                }
            )
        )
    }

    private func makeTradeRecords() -> [TradeRecord] {
        [
            TradeRecord(symbol: "TSLA", tradedAt: makeDate(year: 2026, month: 3, day: 15), shareCount: 200, transactionType: .buy, strategy: .themeBased, targetPrice: 250, stopLoss: 150),
            TradeRecord(symbol: "AAPL", tradedAt: makeDate(year: 2026, month: 3, day: 10), shareCount: 50, transactionType: .sell, strategy: .longTerm),
            TradeRecord(symbol: "NVDA", tradedAt: makeDate(year: 2026, month: 3, day: 5), shareCount: 100, transactionType: .buy, strategy: .longTerm),
            TradeRecord(symbol: "GOOGL", tradedAt: makeDate(year: 2026, month: 2, day: 28), shareCount: 30, transactionType: .sell, strategy: .longTerm),
            TradeRecord(symbol: "MSFT", tradedAt: makeDate(year: 2026, month: 2, day: 15), shareCount: 80, transactionType: .buy, strategy: .longTerm)
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

private actor TradeHistoryStoreMock {
    private var trades: [TradeRecord]

    init(trades: [TradeRecord]) {
        self.trades = trades
    }

    func fetchTrades() -> [TradeRecord] {
        trades.sorted(by: { $0.tradedAt > $1.tradedAt })
    }

    func saveTrade(_ trade: TradeRecord) {
        trades.append(trade)
    }
}
