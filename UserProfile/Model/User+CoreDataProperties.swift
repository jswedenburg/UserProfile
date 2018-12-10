//
//  User+CoreDataProperties.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/4/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var guid: String?
    @NSManaged public var firstName: String
    @NSManaged public var lastName: String
    @NSManaged public var phoneNumber: String
    @NSManaged public var name: String
    @NSManaged public var zipCode: String
    @NSManaged public var email: String
    @NSManaged public var tenant: String
    @NSManaged public var profilePhoto: String?

}
