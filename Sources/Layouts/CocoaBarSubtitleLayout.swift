//
//  CocoaBarSubtitleLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 06/10/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public class CocoaBarSubtitleLayout: CocoaBarLayout {

    // MARK: Properties
    
    /**
     Title label.
     */
    @IBOutlet public weak var titleLabel: UILabel?
    /**
     Subtitle label.
     */
    @IBOutlet public weak var subtitleLabel: UILabel?
    
    // MARK: Lifecycle

    open override func updateLayoutForBackgroundStyle(_ newStyle: BackgroundStyle,
                                                      backgroundView: UIView?) {
        
        switch newStyle {
        case .blurDark:
            self.titleLabel?.textColor = UIColor.white
            self.subtitleLabel?.textColor = UIColor.white
            self.dismissButton?.setTitleColor(UIColor.lightText, for: UIControlState())
        default:
            self.titleLabel?.textColor = UIColor.black
            self.subtitleLabel?.textColor = UIColor.black
            self.dismissButton?.setTitleColor(self.tintColor, for: UIControlState())
        }
    }
    
    open override func prepareLayoutForShowing() {
        super.prepareLayoutForShowing()
        
        // prepare the layout for being shown in a CocoaBar
    }
    
    open override func prepareLayoutForHiding() {
        super.prepareLayoutForHiding()
        
        // prepare the layout for being hidden from a CocoaBar
    }
}
