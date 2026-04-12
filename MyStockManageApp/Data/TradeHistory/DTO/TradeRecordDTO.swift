import Foundation

struct TradeRecordDTO: Equatable, Sendable {
    let id: String
    let symbol: String
    let tradedAt: Date
    let shareCount: Int
    let transactionTypeRawValue: String
    let strategyRawValue: String
    let targetPrice: Double?
    let stopLoss: Double?
    let reasoning: String

    init(
        id: String,
        symbol: String,
        tradedAt: Date,
        shareCount: Int,
        transactionTypeRawValue: String,
        strategyRawValue: String,
        targetPrice: Double?,
        stopLoss: Double?,
        reasoning: String
    ) {
        self.id = id
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.shareCount = shareCount
        self.transactionTypeRawValue = transactionTypeRawValue
        self.strategyRawValue = strategyRawValue
        self.targetPrice = targetPrice
        self.stopLoss = stopLoss
        self.reasoning = reasoning
    }

    init(tradeRecord: TradeRecord) {
        self.init(
            id: tradeRecord.id,
            symbol: tradeRecord.symbol,
            tradedAt: tradeRecord.tradedAt,
            shareCount: tradeRecord.shareCount,
            transactionTypeRawValue: tradeRecord.transactionType.rawValue,
            strategyRawValue: tradeRecord.strategy.rawValue,
            targetPrice: tradeRecord.targetPrice,
            stopLoss: tradeRecord.stopLoss,
            reasoning: tradeRecord.reasoning
        )
    }

    func toDomain() throws -> TradeRecord {
        guard let transactionType = TradeTransactionType(rawValue: transactionTypeRawValue) else {
            throw TradeRecordDTOError.invalidTransactionType(transactionTypeRawValue)
        }

        guard let strategy = TradeStrategy(rawValue: strategyRawValue) else {
            throw TradeRecordDTOError.invalidStrategy(strategyRawValue)
        }

        return TradeRecord(
            id: id,
            symbol: symbol,
            tradedAt: tradedAt,
            shareCount: shareCount,
            transactionType: transactionType,
            strategy: strategy,
            targetPrice: targetPrice,
            stopLoss: stopLoss,
            reasoning: reasoning
        )
    }
}

enum TradeRecordDTOError: Error {
    case invalidTransactionType(String)
    case invalidStrategy(String)
}
