//
//  CocoaBarErrorExpandedLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class CocoaBarErrorExpandedLayout: CocoaBarLayout {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
        switch newStyle {
        case .BlurDark:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.subtitleLabel?.textColor = UIColor.whiteColor()
        default:
            self.titleLabel?.textColor = UIColor.blackColor()
            self.subtitleLabel?.textColor = UIColor.blackColor()
        }
    }
}
