//
//  CocoaBarActionLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 07/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class CocoaBarActionLayout: CocoaBarLayout {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    override func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
        switch newStyle {
        case .BlurDark:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.dismissButton?.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Normal)
        default:
            self.titleLabel?.textColor = UIColor.blackColor()
            self.dismissButton?.setTitleColor(self.tintColor, forState: UIControlState.Normal)
        }
    }
    
}
