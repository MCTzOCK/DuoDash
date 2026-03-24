//
//  ListContainer+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//
//

public import Foundation
public import CoreData


public typealias ListContainerCoreDataPropertiesSet = NSSet

extension ListContainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListContainer> {
        return NSFetchRequest<ListContainer>(entityName: "ListContainer")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var metadata: Data?
    @NSManaged public var symbol: String?
    @NSManaged public var title: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var space: SharedSpace?

}

// MARK: Generated accessors for items
extension ListContainer {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ListItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ListItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension ListContainer : Identifiable {

}
