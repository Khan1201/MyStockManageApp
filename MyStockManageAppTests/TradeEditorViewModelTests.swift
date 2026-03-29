import XCTest
@testable import MyStockManageApp

@MainActor
final class TradeEditorViewModelTests: XCTestCase {
    func testCanSaveRequiresNonEmptySymbol() {
        let sut = TradeEditorViewModel(onDismiss: {}, onSave: { _ in })

        XCTAssertFalse(sut.canSave)

        sut.didUpdateSymbol("TSLA")

        XCTAssertTrue(sut.canSave)
    }

    func testDidChangeQuantityTextFiltersNonNumericCharacters() {
        let sut = TradeEditorViewModel(symbol: "TSLA", quantity: 0, onDismiss: {}, onSave: { _ in })

        sut.didChangeQuantityText("12ab3-4")

        XCTAssertEqual(sut.quantityText, "1234")
        XCTAssertTrue(sut.canSave)
    }

    func testDidTapSaveButtonPersistsTradeAndCallsCallbacks() async {
        let saveSpy = TradeRecordSaveSpy()
        var dismissCount = 0
        var saveCompletionCount = 0
        let sut = TradeEditorViewModel(
            symbol: "TSLA",
            transactionType: .buy,
            tradeDate: makeDate(year: 2026, month: 3, day: 26),
            quantity: 200,
            strategy: .longTerm,
            targetPriceText: "250",
            stopLossText: "150",
            reasoning: "Battery breakout thesis",
            saveTradeUseCase: SaveTradeUseCase(
                operation: { trade in
                    await saveSpy.save(trade)
                }
            ),
            onDismiss: {
                dismissCount += 1
            },
            onSave: { _ in
                saveCompletionCount += 1
            }
        )

        sut.didSelectTransactionType(.sell)
        sut.didSelectStrategy(.themeBased)
        sut.didChangeReasoning("Income rotation")

        await sut.didTapSaveButton()

        let savedTrade = await saveSpy.lastTrade
        XCTAssertEqual(savedTrade?.symbol, "TSLA")
        XCTAssertEqual(savedTrade?.transactionType, .sell)
        XCTAssertEqual(savedTrade?.shareCount, 200)
        XCTAssertEqual(savedTrade?.strategy, .themeBased)
        XCTAssertEqual(savedTrade?.targetPrice, 250)
        XCTAssertEqual(savedTrade?.stopLoss, 150)
        XCTAssertEqual(savedTrade?.reasoning, "Income rotation")
        XCTAssertEqual(saveCompletionCount, 1)
        XCTAssertEqual(dismissCount, 1)
    }

    func testDidTapDiscardButtonRestoresInitialValuesAndDismisses() {
        var dismissCount = 0
        var saveCount = 0
        let sut = TradeEditorViewModel(
            symbol: "TSLA",
            transactionType: .buy,
            tradeDate: makeDate(year: 2026, month: 3, day: 26),
            quantity: 120,
            strategy: .longTerm,
            reasoning: "Initial note",
            onDismiss: {
                dismissCount += 1
            },
            onSave: { _ in
                saveCount += 1
            }
        )

        sut.didUpdateSymbol("NVDA")
        sut.didSelectTransactionType(.sell)
        sut.didChangeQuantityText("45")
        sut.didSelectStrategy(.themeBased)
        sut.didChangeTargetPriceText("250.009")
        sut.didChangeStopLossText("$150.5")
        sut.didChangeReasoning("Updated note")
        sut.didTapDiscardButton()

        XCTAssertEqual(sut.symbol, "TSLA")
        XCTAssertEqual(sut.transactionType, .buy)
        XCTAssertEqual(sut.quantityText, "120")
        XCTAssertEqual(sut.strategy, .longTerm)
        XCTAssertEqual(sut.targetPriceText, "")
        XCTAssertEqual(sut.stopLossText, "")
        XCTAssertEqual(sut.reasoning, "Initial note")
        XCTAssertEqual(dismissCount, 1)
        XCTAssertEqual(saveCount, 0)
    }

    func testThemeBasedStrategyShowsConditionalFields() {
        let sut = TradeEditorViewModel(onDismiss: {}, onSave: { _ in })

        XCTAssertFalse(sut.shouldShowThemeBasedFields)

        sut.didSelectStrategy(.themeBased)

        XCTAssertTrue(sut.shouldShowThemeBasedFields)
    }

    func testDidChangePriceTextsFiltersDecimalInput() {
        let sut = TradeEditorViewModel(onDismiss: {}, onSave: { _ in })

        sut.didChangeTargetPriceText("25a0.345")
        sut.didChangeStopLossText("$15..987")

        XCTAssertEqual(sut.targetPriceText, "250.34")
        XCTAssertEqual(sut.stopLossText, "15.98")
    }

    func testDidTapSaveButtonUsesProvidedTradeID() async {
        let saveSpy = TradeRecordSaveSpy()
        let sut = TradeEditorViewModel(
            tradeID: "existing-trade-id",
            symbol: "TSLA",
            quantity: 10,
            saveTradeUseCase: SaveTradeUseCase(
                operation: { trade in
                    await saveSpy.save(trade)
                }
            ),
            onDismiss: {},
            onSave: { _ in }
        )

        await sut.didTapSaveButton()

        let savedTrade = await saveSpy.lastTrade
        XCTAssertEqual(savedTrade?.id, "existing-trade-id")
    }

    func testDidTapSaveButtonOmitsTargetPriceAndStopLossForLongTermStrategy() async {
        let saveSpy = TradeRecordSaveSpy()
        let sut = TradeEditorViewModel(
            symbol: "TSLA",
            quantity: 10,
            strategy: .longTerm,
            targetPriceText: "250",
            stopLossText: "150",
            saveTradeUseCase: SaveTradeUseCase(
                operation: { trade in
                    await saveSpy.save(trade)
                }
            ),
            onDismiss: {},
            onSave: { _ in }
        )

        await sut.didTapSaveButton()

        let savedTrade = await saveSpy.lastTrade
        XCTAssertNil(savedTrade?.targetPrice)
        XCTAssertNil(savedTrade?.stopLoss)
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
