//
//  LoveNote+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//
//

public import Foundation
public import CoreData


public typealias LoveNoteCoreDataPropertiesSet = NSSet

extension LoveNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoveNote> {
        return NSFetchRequest<LoveNote>(entityName: "LoveNote")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var metadata: Data?
    @NSManaged public var message: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var authorId: String?
    @NSManaged public var space: SharedSpace?

}

extension LoveNote : Identifiable {

}
