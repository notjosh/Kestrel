// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SearchEngine.swift instead.

import Foundation
import CoreData

public enum SearchEngineAttributes: String {
    case key = "key"
    case name = "name"
    case order = "order"
    case template = "template"
}

open class _SearchEngine: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "SearchEngine"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<SearchEngine> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _SearchEngine.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var key: String!

    @NSManaged open
    var name: String!

    @NSManaged open
    var order: Int16

    @NSManaged open
    var template: String!

    // MARK: - Relationships

}

