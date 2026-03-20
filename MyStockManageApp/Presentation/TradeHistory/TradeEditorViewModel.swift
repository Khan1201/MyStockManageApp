import Foundation
import SwiftUI

@MainActor
final class TradeEditorViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published private(set) var symbol: String
    @Published private(set) var transactionType: TradeHistoryTransactionType
    @Published private(set) var tradeDate: Date
    @Published private(set) var quantityText: String
    @Published private(set) var strategy: TradeEditorStrategy
    @Published private(set) var targetPriceText: String
    @Published private(set) var stopLossText: String
    @Published private(set) var reasoning: String
    @Published private(set) var isSaving = false
    @Published private(set) var saveErrorMessage: String?

    private let initialSymbol: String
    private let initialTransactionType: TradeHistoryTransactionType
    private let initialTradeDate: Date
    private let initialQuantityText: String
    private let initialStrategy: TradeEditorStrategy
    private let initialTargetPriceText: String
    private let initialStopLossText: String
    private let initialReasoning: String
    private let saveTradeUseCase: SaveTradeUseCase
    private let onDismiss: () -> Void
    private let onSave: () async -> Void

    init(
        symbol: String = "",
        transactionType: TradeHistoryTransactionType = .buy,
        tradeDate: Date = Date(),
        quantity: Int = 200,
        strategy: TradeEditorStrategy = .longTerm,
        targetPriceText: String = "",
        stopLossText: String = "",
        reasoning: String = "",
        saveTradeUseCase: SaveTradeUseCase = .noop,
        onDismiss: @escaping () -> Void,
        onSave: @escaping () async -> Void
    ) {
        let quantityText = String(max(quantity, 0))

        self.symbol = symbol
        self.transactionType = transactionType
        self.tradeDate = tradeDate
        self.quantityText = quantityText
        self.strategy = strategy
        self.targetPriceText = Self.filterDecimalInput(targetPriceText)
        self.stopLossText = Self.filterDecimalInput(stopLossText)
        self.reasoning = reasoning
        self.initialSymbol = symbol
        self.initialTransactionType = transactionType
        self.initialTradeDate = tradeDate
        self.initialQuantityText = quantityText
        self.initialStrategy = strategy
        self.initialTargetPriceText = Self.filterDecimalInput(targetPriceText)
        self.initialStopLossText = Self.filterDecimalInput(stopLossText)
        self.initialReasoning = reasoning
        self.saveTradeUseCase = saveTradeUseCase
        self.onDismiss = onDismiss
        self.onSave = onSave
    }

    var canSave: Bool {
        !trimmedSymbol.isEmpty && shareCount > 0 && !isSaving
    }

    var shouldShowReasoningPlaceholder: Bool {
        reasoning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var shouldShowThemeBasedFields: Bool {
        strategy == .themeBased
    }

    func didUpdateSymbol(_ symbol: String) {
        self.symbol = symbol
        saveErrorMessage = nil
    }

    func didSelectTransactionType(_ transactionType: TradeHistoryTransactionType) {
        self.transactionType = transactionType
        saveErrorMessage = nil
    }

    func didChangeTradeDate(_ tradeDate: Date) {
        self.tradeDate = tradeDate
        saveErrorMessage = nil
    }

    func didChangeQuantityText(_ quantityText: String) {
        let digitsOnly = quantityText.filter(\.isNumber)
        self.quantityText = String(digitsOnly.prefix(6))
        saveErrorMessage = nil
    }

    func didSelectStrategy(_ strategy: TradeEditorStrategy) {
        self.strategy = strategy
        saveErrorMessage = nil
    }

    func didChangeTargetPriceText(_ targetPriceText: String) {
        self.targetPriceText = Self.filterDecimalInput(targetPriceText)
        saveErrorMessage = nil
    }

    func didChangeStopLossText(_ stopLossText: String) {
        self.stopLossText = Self.filterDecimalInput(stopLossText)
        saveErrorMessage = nil
    }

    func didChangeReasoning(_ reasoning: String) {
        self.reasoning = reasoning
        saveErrorMessage = nil
    }

    func didTapBackButton() {
        onDismiss()
    }

    func didTapDiscardButton() {
        resetDraft()
        onDismiss()
    }

    func didTapSaveButton() async {
        guard canSave else {
            return
        }

        isSaving = true
        saveErrorMessage = nil

        do {
            try await saveTradeUseCase.execute(
                TradeRecord(
                    symbol: trimmedSymbol,
                    tradedAt: tradeDate,
                    shareCount: shareCount,
                    transactionType: transactionType,
                    strategy: strategy,
                    targetPrice: targetPrice,
                    stopLoss: stopLoss,
                    reasoning: trimmedReasoning
                )
            )

            isSaving = false
            await onSave()
            onDismiss()
        } catch {
            isSaving = false
            saveErrorMessage = error.localizedDescription
        }
    }

    private var trimmedSymbol: String {
        symbol.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedReasoning: String {
        reasoning.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var shareCount: Int {
        Int(quantityText) ?? 0
    }

    private var targetPrice: Double? {
        Double(targetPriceText)
    }

    private var stopLoss: Double? {
        Double(stopLossText)
    }

    private func resetDraft() {
        symbol = initialSymbol
        transactionType = initialTransactionType
        tradeDate = initialTradeDate
        quantityText = initialQuantityText
        strategy = initialStrategy
        targetPriceText = initialTargetPriceText
        stopLossText = initialStopLossText
        reasoning = initialReasoning
        saveErrorMessage = nil
    }
}

private extension TradeEditorViewModel {
    static func filterDecimalInput(_ input: String) -> String {
        var result = ""
        var containsDecimalSeparator = false

        for character in input {
            if character.isNumber {
                result.append(character)
                continue
            }

            if character == ".", !containsDecimalSeparator {
                containsDecimalSeparator = true
                result.append(character)
            }
        }

        if let decimalSeparatorIndex = result.firstIndex(of: ".") {
            let decimalStartIndex = result.index(after: decimalSeparatorIndex)
            let decimalDigits = result[decimalStartIndex...].prefix(2)
            result = String(result[..<decimalStartIndex]) + String(decimalDigits)
        }

        return String(result.prefix(9))
    }
}
