import Foundation

struct TradeHistoryTransaction: Identifiable, Equatable {
    let id: String
    let symbol: String
    let tradedAt: Date
    let shareCount: Int
    let transactionType: TradeHistoryTransactionType
    let strategy: TradeEditorStrategy
    let targetPrice: Double?
    let stopLoss: Double?
    let reasoning: String

    init(
        id: String? = nil,
        symbol: String,
        tradedAt: Date,
        shareCount: Int,
        transactionType: TradeHistoryTransactionType,
        strategy: TradeEditorStrategy = .longTerm,
        targetPrice: Double? = nil,
        stopLoss: Double? = nil,
        reasoning: String = ""
    ) {
        self.id = id ?? "\(symbol)-\(Int(tradedAt.timeIntervalSince1970))-\(transactionType.rawValue)-\(shareCount)"
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.shareCount = shareCount
        self.transactionType = transactionType
        self.strategy = strategy
        self.targetPrice = targetPrice
        self.stopLoss = stopLoss
        self.reasoning = reasoning
    }

    var subtitleText: String {
        "\(Self.tradeDateFormatter.string(from: tradedAt)) · \(shareCount) Shares"
    }

    init(tradeRecord: TradeRecord) {
        self.init(
            id: tradeRecord.id,
            symbol: tradeRecord.symbol,
            tradedAt: tradeRecord.tradedAt,
            shareCount: tradeRecord.shareCount,
            transactionType: tradeRecord.transactionType,
            strategy: tradeRecord.strategy,
            targetPrice: tradeRecord.targetPrice,
            stopLoss: tradeRecord.stopLoss,
            reasoning: tradeRecord.reasoning
        )
    }

    private static let tradeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yy/MM/dd"
        return formatter
    }()
}
