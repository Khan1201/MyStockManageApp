import CoreData
import Foundation

final class TradeHistoryPersistentStorage {
    private let persistentStorage: CoreDataPersistentStorage

    init(inMemory: Bool = false) {
        persistentStorage = CoreDataPersistentStorage(
            modelName: "TradeHistoryModel",
            managedObjectModel: Self.makeManagedObjectModel(),
            storeFileName: "TradeHistory.sqlite",
            inMemory: inMemory
        )
    }

    func performBackgroundTask<Result>(
        _ operation: @escaping (NSManagedObjectContext) throws -> Result
    ) async throws -> Result {
        try await persistentStorage.performBackgroundTask(operation)
    }
}

private extension TradeHistoryPersistentStorage {
    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = StoredTradeRecordManagedObject.entityName
        entity.managedObjectClassName = NSStringFromClass(StoredTradeRecordManagedObject.self)
        entity.properties = [
            makeAttribute(name: "id", type: .stringAttributeType),
            makeAttribute(name: "symbol", type: .stringAttributeType),
            makeAttribute(name: "tradedAt", type: .dateAttributeType),
            makeAttribute(name: "shareCount", type: .integer64AttributeType),
            makeAttribute(name: "transactionTypeRawValue", type: .stringAttributeType),
            makeAttribute(name: "strategyRawValue", type: .stringAttributeType),
            makeAttribute(name: "targetPrice", type: .doubleAttributeType, isOptional: true),
            makeAttribute(name: "stopLoss", type: .doubleAttributeType, isOptional: true),
            makeAttribute(name: "reasoning", type: .stringAttributeType)
        ]
        entity.uniquenessConstraints = [["id"]]
        model.entities = [entity]
        return model
    }

    static func makeAttribute(
        name: String,
        type: NSAttributeType,
        isOptional: Bool = false
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        return attribute
    }
}
