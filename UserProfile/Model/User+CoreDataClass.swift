//
//  User+CoreDataClass.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/4/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject, Encodable {
    
    static let entityDescription = "User"
    
    enum CodingKeys: String, CodingKey {
        case guid
        case name
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case zipCode = "zipcode"
        case tenant
        case profilePhoto = "profile_photo"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guid, forKey: .guid)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(tenant, forKey: .tenant)
        try container.encode(profilePhoto, forKey: .profilePhoto)
    }

    convenience init (dict: [String:AnyObject]) {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: CoreDataStack.context)!
        self.init(entity: entity, insertInto: CoreDataStack.context)
        self.guid = dict[CodingKeys.guid.rawValue] as? String ?? ""
        self.name = dict[CodingKeys.name.rawValue] as? String ?? ""
        self.email = dict[CodingKeys.email.rawValue] as? String ?? ""
        self.firstName = dict[CodingKeys.firstName.rawValue] as? String ?? ""
        self.lastName = dict["Last_name"] as? String ?? ""
        self.phoneNumber = dict[CodingKeys.phoneNumber.rawValue] as? String ?? ""
        self.zipCode = dict[CodingKeys.zipCode.rawValue] as? String ?? ""
        self.tenant = dict[CodingKeys.tenant.rawValue] as? String ?? ""
        self.profilePhoto = dict[CodingKeys.profilePhoto.rawValue] as? String
    }
    
    func updateIdFrom(data: Data)  {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
                self.guid = json[CodingKeys.guid.rawValue] as? String ?? ""
            }
        } catch let error {
            print(error)
        }
    }
    
    func updateProfilePicFrom(data: Data)  {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]] {
                self.profilePhoto = json[0][CodingKeys.profilePhoto.rawValue] as? String ?? ""
            }
        } catch let error {
            print(error)
        }
    }
}
