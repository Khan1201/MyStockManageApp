import Foundation

struct TradeRecord: Identifiable, Equatable, Sendable {
    let id: String
    let symbol: String
    let tradedAt: Date
    let shareCount: Int
    let transactionType: TradeTransactionType
    let strategy: TradeStrategy
    let targetPrice: Double?
    let stopLoss: Double?
    let reasoning: String

    init(
        id: String = UUID().uuidString,
        symbol: String,
        tradedAt: Date,
        shareCount: Int,
        transactionType: TradeTransactionType,
        strategy: TradeStrategy,
        targetPrice: Double? = nil,
        stopLoss: Double? = nil,
        reasoning: String = ""
    ) {
        self.id = id
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.shareCount = shareCount
        self.transactionType = transactionType
        self.strategy = strategy
        self.targetPrice = targetPrice
        self.stopLoss = stopLoss
        self.reasoning = reasoning
    }
}
