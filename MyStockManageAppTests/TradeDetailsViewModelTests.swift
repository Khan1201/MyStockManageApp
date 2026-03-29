import XCTest
@testable import MyStockManageApp

@MainActor
final class TradeDetailsViewModelTests: XCTestCase {
    func testThemeBasedTransactionShowsConditionalFields() {
        let sut = TradeDetailsViewModel(
            transaction: makeTransaction(strategy: .themeBased),
            onDismiss: {}
        )

        XCTAssertTrue(sut.shouldShowThemeBasedFields)
        XCTAssertEqual(sut.targetPriceText, "$ 250.00")
        XCTAssertEqual(sut.stopLossText, "$ 150.00")
    }

    func testLongTermTransactionHidesConditionalFields() {
        let sut = TradeDetailsViewModel(
            transaction: makeTransaction(strategy: .longTerm),
            onDismiss: {}
        )

        XCTAssertFalse(sut.shouldShowThemeBasedFields)
    }

    func testDidTapEditButtonPresentsEditorWithTransactionValues() {
        let sut = TradeDetailsViewModel(
            transaction: makeTransaction(strategy: .themeBased),
            onDismiss: {}
        )

        sut.didTapEditButton()

        XCTAssertEqual(sut.tradeEditorViewModel?.symbol, "TSLA")
        XCTAssertEqual(sut.tradeEditorViewModel?.quantityText, "200")
        XCTAssertEqual(sut.tradeEditorViewModel?.strategy, .themeBased)
        XCTAssertEqual(sut.tradeEditorViewModel?.targetPriceText, "250")
        XCTAssertEqual(sut.tradeEditorViewModel?.stopLossText, "150")
    }

    func testSavingFromPresentedEditorUpdatesTransactionAndCallsSaveHandler() async {
        let saveSpy = TradeRecordSaveSpy()
        let callbackSpy = TradeDetailsCallbackSpy()
        let sut = TradeDetailsViewModel(
            transaction: makeTransaction(strategy: .themeBased),
            saveTradeUseCase: SaveTradeUseCase(
                operation: { trade in
                    await saveSpy.save(trade)
                }
            ),
            onDismiss: {},
            onTradeSaved: { trade in
                await callbackSpy.recordSavedTradeID(trade.id)
            }
        )

        sut.didTapEditButton()
        sut.tradeEditorViewModel?.didChangeQuantityText("240")
        sut.tradeEditorViewModel?.didChangeTargetPriceText("315")
        await sut.tradeEditorViewModel?.didTapSaveButton()

        let recordedTradeID = await callbackSpy.savedTradeID()
        XCTAssertEqual(sut.transaction.shareCount, 240)
        XCTAssertEqual(sut.transaction.targetPrice, 315)
        XCTAssertEqual(recordedTradeID, sut.transaction.id)

        let savedTrade = await saveSpy.lastTrade
        XCTAssertEqual(savedTrade?.id, sut.transaction.id)
    }

    private func makeTransaction(strategy: TradeEditorStrategy) -> TradeHistoryTransaction {
        TradeHistoryTransaction(
            id: "trade-1",
            symbol: "TSLA",
            tradedAt: makeDate(year: 2026, month: 3, day: 15),
            shareCount: 200,
            transactionType: .buy,
            strategy: strategy,
            targetPrice: 250,
            stopLoss: 150,
            reasoning: "Battery breakout thesis"
        )
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

private actor TradeRecordSaveSpy {
    private(set) var savedTrades: [TradeRecord] = []

    func save(_ trade: TradeRecord) {
        savedTrades.append(trade)
    }

    var lastTrade: TradeRecord? {
        savedTrades.last
    }
}

private actor TradeDetailsCallbackSpy {
    private var storedTradeID: String?

    func recordSavedTradeID(_ tradeID: String) {
        storedTradeID = tradeID
    }

    func savedTradeID() -> String? {
        storedTradeID
    }
}
