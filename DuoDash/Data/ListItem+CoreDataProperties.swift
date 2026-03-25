//
//  ListItem+CoreDataProperties.swift
//  
//
//  Created by Ben Siebert on 25.03.26.
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
    @NSManaged public var text: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var container: ListContainer?

}

extension ListItem : Identifiable {
    
}
