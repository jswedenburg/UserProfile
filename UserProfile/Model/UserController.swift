//
//  UserController.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/5/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import Foundation
import CoreData

typealias ResponseClosure = (_ success: Bool, _ errorMessage: String?) -> Void

class UserController:NSObject {
    
    static let shared = UserController()
    private override init() {}
    
    func fetchUsers() {
        let manager = NetworkManager()
        manager.dataRequestForUrl(url: manager.getUsersUrl(), httpMethod: .Get) { (result) in
            switch result {
            case .Success(let data):
                //If successful, clear the existing users from the store
                self.clearAllUsers()
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]] {
                        for userJson in json {
                            let _ = User(dict: userJson)
                        }
                        
                    }
                    
                } catch let error {
                    print(error)
                }
                
                CoreDataStack.saveContext()
            case .Error(let message):
                print(message)
                break
            }
        }
    }
    
    func addUser(user: User, completion: @escaping ResponseClosure) {
        let encoder = JSONEncoder()
        let userData = try? encoder.encode(user)
        let manager = NetworkManager()
        manager.dataRequestForUrl(url: manager.getUsersUrl(), httpMethod: .Post, body: userData) { (result) in
            
            switch result {
            case .Success(let data):
                user.updateIdFrom(data: data)
                completion(true, nil)
            case .Error(let message):
                completion(false, message)
                print(message)
            }
        }
    }
    
    
    func updateUser(user: User, completion: @escaping ResponseClosure) {
        let encoder = JSONEncoder()
        let userData = try? encoder.encode(user)
        let manager = NetworkManager()
        manager.dataRequestForUrl(url: manager.getUserUrl(id: user.guid ?? ""), httpMethod: .Patch, body: userData) { (result) in
            switch result {
            case .Success(_):
                completion(true, nil)
            case .Error(let message):
                completion(false, message)
                print(message)
            }
        }
    }
    
    func deleteUser(user: User) {
        CoreDataStack.context.delete(user)
        CoreDataStack.saveContext()
    }
    
    func clearAllUsers() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityDescription)
        let context = CoreDataStack.context
        do {
            let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            CoreDataStack.saveContext()
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
}
