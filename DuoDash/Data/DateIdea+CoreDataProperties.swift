//
//  DateIdea+CoreDataProperties.swift
//  
//
//  Created by Ben Siebert on 25.03.26.
//
//

public import Foundation
public import CoreData


public typealias DateIdeaCoreDataPropertiesSet = NSSet

extension DateIdea {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DateIdea> {
        return NSFetchRequest<DateIdea>(entityName: "DateIdea")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var isDone: Bool
    @NSManaged public var location: String?
    @NSManaged public var metadata: Data?
    @NSManaged public var priceLevel: Int16
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var urlString: String?
    @NSManaged public var category: String?
    @NSManaged public var space: SharedSpace?

}

extension DateIdea: Identifiable {
    
}
