//
//  Profile+CoreDataProperties.swift
//  
//
//  Created by leeyuno on 2017. 6. 21..
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var age: String?
    @NSManaged public var deviceId: String?
    @NSManaged public var email: String?
    @NSManaged public var gender: String?
    @NSManaged public var hobby: String?
    @NSManaged public var imageId: String?
    @NSManaged public var job: String?
    @NSManaged public var nick: String?
    @NSManaged public var password: String?
    @NSManaged public var pers: String?
    @NSManaged public var spec: String?
    @NSManaged public var spot: String?

}
