//
//  UserDetailViewController.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/6/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import UIKit
import CoreData

class UserDetailViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var txtFieldFirstName:UITextField!
    @IBOutlet weak var txtFieldLastName:UITextField!
    @IBOutlet weak var txtFieldName:UITextField!
    @IBOutlet weak var txtFieldEmail:UITextField!
    @IBOutlet weak var txtFieldPhone:UITextField!
    @IBOutlet weak var txtFieldZip:UITextField!
    @IBOutlet weak var txtFieldTenant:UITextField!
    @IBOutlet var txtFields: [UITextField]!
    
    var action:UserAction = UserAction.create
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateFields()
        imgViewProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImgTapped)))
        txtFields.forEach({$0.delegate = self})
    }
    
    
    //MARK: Initial Setup
    func populateFields() {
        switch action {
        case .create:
            lblTitle.text = "Add a new user"
            //No need to populate if created
            break
        case .update(let user):
            lblTitle.text = "Update \(user.firstName)"
            txtFieldFirstName.text = user.firstName
            txtFieldLastName.text = user.lastName
            txtFieldEmail.text = user.email
            txtFieldPhone.text = user.phoneNumber
            txtFieldZip.text = user.zipCode
            txtFieldName.text = user.name
            txtFieldTenant.text = user.tenant
            fetchProfilePhoto(user: user)
        }
    }
    
    func fetchProfilePhoto(user: User) {
        if let _ = user.profilePhoto {
            setProfilePic(user: user)
            return
        }
        
        showProgressIndicator()
        
        UserController.shared.fetchUserProfilePic(user: user) { (success, error) in
            if success {
                CoreDataStack.saveContext()
            }
            DispatchQueue.main.async {
                self.hideProgressIndicator()
                self.setProfilePic(user: user)
            }
        }
    }
    
    func setProfilePic(user: User) {
        if let base64String = user.profilePhoto, let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            self.imgViewProfile.image = UIImage(data: data)
        } else {
            self.imgViewProfile.image = UIImage(named: "ic_user")
        }
    }
    
    
    //MARK: User Interaction
    @objc func profileImgTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Libarary", style: .default, handler: { (_) in
            self.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        showProgressIndicator()
        switch action {
        case .create:
            let newUser = NSEntityDescription.insertNewObject(forEntityName: User.entityDescription, into: CoreDataStack.context) as! User
            updateUserWithFields(user: newUser)
            UserController.shared.addUser(user: newUser) { (success, error) in
                if success {
                    CoreDataStack.saveContext()
                    DispatchQueue.main.async {
                        self.hideProgressIndicator()
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    //If save fails, delete user from store and show error message
                    UserController.shared.deleteUser(user: newUser)
                    DispatchQueue.main.async {
                        self.hideProgressIndicator()
                        self.showErrorWith(message: "Failed to add user. Try again later")
                    }
                }
            }
        case .update(let user):
            updateUserWithFields(user: user)
            UserController.shared.updateUser(user: user) { (success, error) in
                if success {
                    CoreDataStack.saveContext()
                    DispatchQueue.main.async {
                       self.hideProgressIndicator()
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    // If update fails, discard changes made to user
                    if CoreDataStack.context.hasChanges {
                        CoreDataStack.context.rollback()
                    }
                    DispatchQueue.main.async {
                        self.hideProgressIndicator()
                        self.showErrorWith(message: "Failed to update user. Try again later")
                    }
                }
            }
        }
    }
    
    //MARK: Helper Methods
    var progressView = UIActivityIndicatorView()
    func showProgressIndicator() {
        let progressSize: CGFloat = 30.0
        progressView = UIActivityIndicatorView(frame: CGRect(x: (self.view.frame.width / 2.0) - progressSize / 2.0, y: (self.view.frame.height / 2.0) - progressSize / 2.0, width: progressSize, height: progressSize))
        progressView.style = .gray
        self.view.addSubview(progressView)
        progressView.startAnimating()
    }
    
    func hideProgressIndicator() {
        progressView.removeFromSuperview()
    }
    func updateUserWithFields(user: User) {
        user.firstName = txtFieldFirstName.text ?? ""
        user.lastName = txtFieldLastName.text ?? ""
        user.email = txtFieldEmail.text ?? ""
        user.name = txtFieldName.text ?? ""
        user.zipCode = txtFieldZip.text ?? ""
        user.phoneNumber = txtFieldPhone.text ?? ""
        user.tenant = txtFieldTenant.text ?? ""
        if let image = imgViewProfile.image {
            user.profilePhoto = image.toBase64String(compressedSize: CGFloat(0.512))
        }
    }
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func showErrorWith(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UserDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgViewProfile.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension UserDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFieldFirstName {
            txtFieldLastName.becomeFirstResponder()
        } else if textField == txtFieldLastName {
            txtFieldName.becomeFirstResponder()
        } else if textField == txtFieldName {
            txtFieldEmail.becomeFirstResponder()
        } else if textField == txtFieldEmail {
            txtFieldPhone.becomeFirstResponder()
        } else if textField == txtFieldPhone {
            txtFieldZip.becomeFirstResponder()
        } else if textField == txtFieldZip {
            txtFieldTenant.becomeFirstResponder()
        }
        
        return true
    }
}
