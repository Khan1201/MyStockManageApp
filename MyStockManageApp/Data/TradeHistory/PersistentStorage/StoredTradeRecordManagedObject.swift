import CoreData
import Foundation

@objc(StoredTradeRecordManagedObject)
final class StoredTradeRecordManagedObject: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var symbol: String
    @NSManaged var tradedAt: Date
    @NSManaged var shareCount: Int64
    @NSManaged var transactionTypeRawValue: String
    @NSManaged var strategyRawValue: String
    @NSManaged var targetPrice: NSNumber?
    @NSManaged var stopLoss: NSNumber?
    @NSManaged var reasoning: String
}

extension StoredTradeRecordManagedObject {
    static func fetchRequest() -> NSFetchRequest<StoredTradeRecordManagedObject> {
        NSFetchRequest<StoredTradeRecordManagedObject>(entityName: entityName)
    }

    static let entityName = "StoredTradeRecord"
}
