//
//  ListItem+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//
//

public import Foundation
public import CoreData


public typealias ListItemCoreDataPropertiesSet = NSSet

extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var metadata: Data?
    @NSManaged public var title: String?
    @NSManaged public var container: ListContainer?

}

extension ListItem : Identifiable {

}
