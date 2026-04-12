import CoreData
import Foundation

final class CoreDataTradeHistoryLocalDataSource: TradeHistoryLocalDataSource {
    private let persistentStorage: TradeHistoryPersistentStorage

    init(persistentStorage: TradeHistoryPersistentStorage) {
        self.persistentStorage = persistentStorage
    }

    func fetchTrades() async throws -> [TradeRecordDTO] {
        try await persistentStorage.performBackgroundTask { context in
            let request = StoredTradeRecordManagedObject.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "tradedAt", ascending: false)]

            return try context.fetch(request).map(TradeRecordDTO.init(managedObject:))
        }
    }

    func saveTrade(_ trade: TradeRecordDTO) async throws {
        try await persistentStorage.performBackgroundTask { context in
            let request = StoredTradeRecordManagedObject.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %@", trade.id)

            let managedObject = try context.fetch(request).first ?? StoredTradeRecordManagedObject(context: context)
            managedObject.id = trade.id
            managedObject.symbol = trade.symbol
            managedObject.tradedAt = trade.tradedAt
            managedObject.shareCount = Int64(trade.shareCount)
            managedObject.transactionTypeRawValue = trade.transactionTypeRawValue
            managedObject.strategyRawValue = trade.strategyRawValue
            managedObject.targetPrice = trade.targetPrice as NSNumber?
            managedObject.stopLoss = trade.stopLoss as NSNumber?
            managedObject.reasoning = trade.reasoning

            if context.hasChanges {
                try context.save()
            }
        }
    }
}

private extension TradeRecordDTO {
    init(managedObject: StoredTradeRecordManagedObject) {
        id = managedObject.id
        symbol = managedObject.symbol
        tradedAt = managedObject.tradedAt
        shareCount = Int(managedObject.shareCount)
        transactionTypeRawValue = managedObject.transactionTypeRawValue
        strategyRawValue = managedObject.strategyRawValue
        targetPrice = managedObject.targetPrice?.doubleValue
        stopLoss = managedObject.stopLoss?.doubleValue
        reasoning = managedObject.reasoning
    }
}
