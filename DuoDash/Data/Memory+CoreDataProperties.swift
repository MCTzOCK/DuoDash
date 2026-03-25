//
//  Memory+CoreDataProperties.swift
//  
//
//  Created by Ben Siebert on 25.03.26.
//
//

public import Foundation
public import CoreData


public typealias MemoryCoreDataPropertiesSet = NSSet

extension Memory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var bodyText: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var metadata: Data?
    @NSManaged public var photoData: Data?
    @NSManaged public var title: String?
    @NSManaged public var location: String?
    @NSManaged public var space: SharedSpace?

}

extension Memory: Identifiable {
    
}
