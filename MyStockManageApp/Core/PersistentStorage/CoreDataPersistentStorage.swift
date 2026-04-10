import CoreData
import Foundation

final class CoreDataPersistentStorage {
    private let container: NSPersistentContainer
    private let loadError: Error?

    init(
        modelName: String,
        managedObjectModel: NSManagedObjectModel,
        storeFileName: String,
        applicationSupportSubdirectory: String = "MyStockManageApp",
        inMemory: Bool = false
    ) {
        container = NSPersistentContainer(
            name: modelName,
            managedObjectModel: managedObjectModel
        )

        let description = NSPersistentStoreDescription()
        description.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false

        if !inMemory {
            description.url = Self.defaultStoreURL(
                fileName: storeFileName,
                applicationSupportSubdirectory: applicationSupportSubdirectory
            )
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

private extension CoreDataPersistentStorage {
    static func defaultStoreURL(
        fileName: String,
        applicationSupportSubdirectory: String
    ) -> URL? {
        let fileManager = FileManager.default

        guard let applicationSupportDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let directory = applicationSupportDirectory.appendingPathComponent(
            applicationSupportSubdirectory,
            isDirectory: true
        )

        do {
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        } catch {
            return nil
        }

        return directory.appendingPathComponent(fileName)
    }
}
