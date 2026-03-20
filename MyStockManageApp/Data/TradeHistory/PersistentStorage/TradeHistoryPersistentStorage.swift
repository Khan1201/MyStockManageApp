import CoreData
import Foundation

final class TradeHistoryPersistentStorage {
    let container: NSPersistentContainer

    private let loadError: Error?

    init(inMemory: Bool = false) {
        let managedObjectModel = Self.makeManagedObjectModel()
        container = NSPersistentContainer(name: "TradeHistoryModel", managedObjectModel: managedObjectModel)

        let description = NSPersistentStoreDescription()
        description.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false

        if !inMemory, let storeURL = Self.defaultStoreURL() {
            description.url = storeURL
        }

        container.persistentStoreDescriptions = [description]

        var persistentStoreLoadError: Error?
        container.loadPersistentStores { _, error in
            persistentStoreLoadError = error
        }

        loadError = persistentStoreLoadError
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func performBackgroundTask<Result>(
        _ operation: @escaping (NSManagedObjectContext) throws -> Result
    ) async throws -> Result {
        if let loadError {
            throw loadError
        }

        return try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                do {
                    let result = try operation(context)
                    continuation.resume(returning: result)
                } catch {
                    context.rollback()
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

private extension TradeHistoryPersistentStorage {
    static func defaultStoreURL() -> URL? {
        let fileManager = FileManager.default

        guard let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        let directory = applicationSupportDirectory.appendingPathComponent("MyStockManageApp", isDirectory: true)

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        return directory.appendingPathComponent("TradeHistory.sqlite")
    }

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
