//
//  Profile+CoreDataProperties.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//
//

public import Foundation
public import CoreData


public typealias ProfileCoreDataPropertiesSet = NSSet

extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var metadata: Data?
    @NSManaged public var name: String?
    @NSManaged public var space: SharedSpace?

}

extension Profile : Identifiable {

}
