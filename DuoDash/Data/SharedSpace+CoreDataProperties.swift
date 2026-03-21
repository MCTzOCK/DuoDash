//
//  SharedSpace+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//
//

public import Foundation
public import CoreData


public typealias SharedSpaceCoreDataPropertiesSet = NSSet

extension SharedSpace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharedSpace> {
        return NSFetchRequest<SharedSpace>(entityName: "SharedSpace")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var joinDate: Date?
    @NSManaged public var metadata: Data?
    @NSManaged public var countdowns: NSSet?
    @NSManaged public var lists: NSSet?
    @NSManaged public var profiles: NSSet?
    @NSManaged public var dateIdeas: NSSet?
    @NSManaged public var calendarEvents: NSSet?
    @NSManaged public var memories: NSSet?
    @NSManaged public var loveNotes: NSSet?

}

// MARK: Generated accessors for countdowns
extension SharedSpace {

    @objc(addCountdownsObject:)
    @NSManaged public func addToCountdowns(_ value: Countdown)

    @objc(removeCountdownsObject:)
    @NSManaged public func removeFromCountdowns(_ value: Countdown)

    @objc(addCountdowns:)
    @NSManaged public func addToCountdowns(_ values: NSSet)

    @objc(removeCountdowns:)
    @NSManaged public func removeFromCountdowns(_ values: NSSet)

}

// MARK: Generated accessors for lists
extension SharedSpace {

    @objc(addListsObject:)
    @NSManaged public func addToLists(_ value: ListContainer)

    @objc(removeListsObject:)
    @NSManaged public func removeFromLists(_ value: ListContainer)

    @objc(addLists:)
    @NSManaged public func addToLists(_ values: NSSet)

    @objc(removeLists:)
    @NSManaged public func removeFromLists(_ values: NSSet)

}

// MARK: Generated accessors for profiles
extension SharedSpace {

    @objc(addProfilesObject:)
    @NSManaged public func addToProfiles(_ value: Profile)

    @objc(removeProfilesObject:)
    @NSManaged public func removeFromProfiles(_ value: Profile)

    @objc(addProfiles:)
    @NSManaged public func addToProfiles(_ values: NSSet)

    @objc(removeProfiles:)
    @NSManaged public func removeFromProfiles(_ values: NSSet)

}

// MARK: Generated accessors for dateIdeas
extension SharedSpace {

    @objc(addDateIdeasObject:)
    @NSManaged public func addToDateIdeas(_ value: DateIdea)

    @objc(removeDateIdeasObject:)
    @NSManaged public func removeFromDateIdeas(_ value: DateIdea)

    @objc(addDateIdeas:)
    @NSManaged public func addToDateIdeas(_ values: NSSet)

    @objc(removeDateIdeas:)
    @NSManaged public func removeFromDateIdeas(_ values: NSSet)

}

// MARK: Generated accessors for calendarEvents
extension SharedSpace {

    @objc(addCalendarEventsObject:)
    @NSManaged public func addToCalendarEvents(_ value: CalendarEvent)

    @objc(removeCalendarEventsObject:)
    @NSManaged public func removeFromCalendarEvents(_ value: CalendarEvent)

    @objc(addCalendarEvents:)
    @NSManaged public func addToCalendarEvents(_ values: NSSet)

    @objc(removeCalendarEvents:)
    @NSManaged public func removeFromCalendarEvents(_ values: NSSet)

}

// MARK: Generated accessors for memories
extension SharedSpace {

    @objc(addMemoriesObject:)
    @NSManaged public func addToMemories(_ value: Memory)

    @objc(removeMemoriesObject:)
    @NSManaged public func removeFromMemories(_ value: Memory)

    @objc(addMemories:)
    @NSManaged public func addToMemories(_ values: NSSet)

    @objc(removeMemories:)
    @NSManaged public func removeFromMemories(_ values: NSSet)

}

// MARK: Generated accessors for loveNotes
extension SharedSpace {

    @objc(addLoveNotesObject:)
    @NSManaged public func addToLoveNotes(_ value: LoveNote)

    @objc(removeLoveNotesObject:)
    @NSManaged public func removeFromLoveNotes(_ value: LoveNote)

    @objc(addLoveNotes:)
    @NSManaged public func addToLoveNotes(_ values: NSSet)

    @objc(removeLoveNotes:)
    @NSManaged public func removeFromLoveNotes(_ values: NSSet)

}

extension SharedSpace : Identifiable {

}
