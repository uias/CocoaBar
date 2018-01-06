//
//  ColorUtils.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 06/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        let actualRed = CGFloat(red) / 255
        let actualGreen = CGFloat(green) / 255
        let actualBlue = CGFloat(blue) / 255
        
        self.init(red: actualRed, green: actualGreen, blue: actualBlue, alpha: 1.0)
    }
}
