//
//  ViewController.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/4/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import UIKit
import CoreData

enum UserAction {
    case create
    case update(user: User)
}

class UsersViewController: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    let detailSegueId = "goToDetail"
    var detailAction:UserAction = UserAction.create
    var selectedUser:User?
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let request:NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors =  [NSSortDescriptor(key: "firstName", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUsers()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func updateUsers() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching users")
        }
        UserController.shared.fetchUsers()
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        detailAction = UserAction.create
        self.performSegue(withIdentifier: detailSegueId, sender: self)
    }
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        UserController.shared.fetchUsers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueId {
            let detailVC = segue.destination as? UserDetailViewController
            detailVC?.action = detailAction
        }
    }
    
}

extension UsersViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexToAdd = newIndexPath {
                tableView.insertRows(at: [indexToAdd], with: .automatic)
            }
        case .update:
            if let indexToUpdate = indexPath {
                let cell = tableView.cellForRow(at: indexToUpdate) as? UserTableViewCell
                let user = fetchedResultsController.object(at: indexToUpdate)
                cell?.updateWith(user: user)
            }
        case .delete:
            if let indexToDelete = indexPath {
                tableView.deleteRows(at: [indexToDelete], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserTableViewCell else { return UITableViewCell() }
        let user = fetchedResultsController.object(at: indexPath)
        cell.updateWith(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = fetchedResultsController.object(at: indexPath)
        detailAction = UserAction.update(user: user)
        self.performSegue(withIdentifier: detailSegueId, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

