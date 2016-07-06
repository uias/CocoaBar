//
//  CocoaBarDefaultLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 07/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public class CocoaBarDefaultLayout: CocoaBarLayout {
    
    @IBOutlet public weak var titleLabel: UILabel?

    public override func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
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
