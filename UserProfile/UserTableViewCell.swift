//
//  UserTableViewCell.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/4/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewProfilePic: UIImageView!
    
    func updateWith(user: User) {
        lblName.text = "\(user.firstName) \(user.lastName)"
        if let profileDate = user.profilePhoto {
            let data = Data(base64Encoded: profileDate, options: .ignoreUnknownCharacters)!
            imgViewProfilePic.image = UIImage(data: data)
            
        } else {
            imgViewProfilePic.image = UIImage(named: "ic_user")
        }
    }

}
