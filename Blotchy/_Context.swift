// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Context.swift instead.

import Foundation
import CoreData

public enum ContextAttributes: String {
    case colorTransformable = "colorTransformable"
    case name = "name"
    case termsTransformable = "termsTransformable"
}

public enum ContextRelationships: String {
    case searchEngine = "searchEngine"
}

open class _Context: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Context"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Context.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var colorTransformable: AnyObject

    @NSManaged open
    var name: String

    @NSManaged open
    var termsTransformable: AnyObject

    // MARK: - Relationships

    @NSManaged open
    var searchEngine: SearchEngine

}

