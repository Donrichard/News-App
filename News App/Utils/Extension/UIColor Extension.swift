//
//  UIColor Extension.swift
//  News App
//
//  Created by Richard Richard on 14/07/18.
//  Copyright © 2018 Richard. All rights reserved.
//

import UIKit

extension UIColor {
    struct CustomColor {
        struct Red {
            static let baseRed = UIColor(hexCode: 0xBB1719)
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hexCode: Int) {
        self.init(red:(hexCode >> 16) & 0xff, green:(hexCode >> 8) & 0xff, blue:hexCode & 0xff)
    }
}
