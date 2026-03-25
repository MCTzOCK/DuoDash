//
//  CalendarEvent+CoreDataProperties.swift
//  
//
//  Created by Ben Siebert on 25.03.26.
//
//

public import Foundation
public import CoreData


public typealias CalendarEventCoreDataPropertiesSet = NSSet

extension CalendarEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarEvent> {
        return NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isAllDay: Bool
    @NSManaged public var metadata: Data?
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var location: String?
    @NSManaged public var url: String?
    @NSManaged public var text: String?
    @NSManaged public var space: SharedSpace?

}

extension CalendarEvent : Identifiable {
}
