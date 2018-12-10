//
//  Extensions.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/9/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func toBase64String() -> String {
        guard let imageData = self.jpegData(compressionQuality: 0.25) else { return "" }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
}
