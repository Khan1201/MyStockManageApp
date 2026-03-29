import SwiftUI

@MainActor
final class TradeDetailsViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published private(set) var transaction: TradeHistoryTransaction
    @Published private(set) var tradeEditorViewModel: TradeEditorViewModel?

    private let saveTradeUseCase: SaveTradeUseCase
    private let onDismiss: () -> Void
    private let onTradeSaved: (TradeRecord) async -> Void

    init(
        transaction: TradeHistoryTransaction,
        saveTradeUseCase: SaveTradeUseCase = .noop,
        onDismiss: @escaping () -> Void,
        onTradeSaved: @escaping (TradeRecord) async -> Void = { _ in }
    ) {
        self.transaction = transaction
        self.saveTradeUseCase = saveTradeUseCase
        self.onDismiss = onDismiss
        self.onTradeSaved = onTradeSaved
    }

    var symbolText: String {
        transaction.symbol
    }

    var tradeDateText: String {
        Self.tradeDateFormatter.string(from: transaction.tradedAt)
    }

    var shareCountText: String {
        "\(transaction.shareCount) Shares"
    }

    var reasoningText: String {
        let trimmedReasoning = transaction.reasoning.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedReasoning.isEmpty ? "-" : trimmedReasoning
    }

    var targetPriceText: String {
        priceText(for: transaction.targetPrice)
    }

    var stopLossText: String {
        priceText(for: transaction.stopLoss)
    }

    var shouldShowThemeBasedFields: Bool {
        transaction.strategy == .themeBased
    }

    func didTapBackButton() {
        onDismiss()
    }

    func didTapEditButton() {
        guard tradeEditorViewModel == nil else {
            return
        }

        tradeEditorViewModel = TradeEditorViewModel(
            tradeID: transaction.id,
            symbol: transaction.symbol,
            transactionType: transaction.transactionType,
            tradeDate: transaction.tradedAt,
            quantity: transaction.shareCount,
            strategy: transaction.strategy,
            targetPriceText: transaction.targetPrice.map(Self.rawPriceText) ?? "",
            stopLossText: transaction.stopLoss.map(Self.rawPriceText) ?? "",
            reasoning: transaction.reasoning,
            saveTradeUseCase: saveTradeUseCase,
            onDismiss: { [weak self] in
                self?.didDismissTradeEditor()
            },
            onSave: { [weak self] savedTrade in
                guard let self else {
                    return
                }

                self.transaction = TradeHistoryTransaction(tradeRecord: savedTrade)
                await self.onTradeSaved(savedTrade)
            }
        )
    }

    func didDismissTradeEditor() {
        tradeEditorViewModel = nil
    }

    func didTapPerformanceAnalyticsButton() {}

    private func priceText(for price: Double?) -> String {
        guard let price, let formattedPrice = Self.currencyFormatter.string(from: NSNumber(value: price)) else {
            return "-"
        }

        return "$ \(formattedPrice)"
    }
}

private extension TradeDetailsViewModel {
    static let tradeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yy/MM/dd"
        return formatter
    }()

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func rawPriceText(_ price: Double) -> String {
        let roundedPrice = (price * 100).rounded() / 100
        return roundedPrice == roundedPrice.rounded()
        ? String(format: "%.0f", roundedPrice)
        : String(format: "%.2f", roundedPrice)
    }
}
