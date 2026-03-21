//
//  Countdown+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//
//

public import Foundation
public import CoreData


public typealias CountdownCoreDataPropertiesSet = NSSet

extension Countdown {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Countdown> {
        return NSFetchRequest<Countdown>(entityName: "Countdown")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageData: UUID?
    @NSManaged public var metadata: Data?
    @NSManaged public var targetDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var space: SharedSpace?

}

extension Countdown : Identifiable {

}
