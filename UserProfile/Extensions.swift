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
    func toBase64String(compressedSize:CGFloat) -> String {
        let sizeInBytes = Int(compressedSize * 1024 * 1024)
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            return data.base64EncodedString(options: .lineLength64Characters)
        }
        
        return ""
    }
}
