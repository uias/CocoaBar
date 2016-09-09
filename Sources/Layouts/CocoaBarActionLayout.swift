//
//  CocoaBarActionLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 07/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

open class CocoaBarActionLayout: CocoaBarLayout {
    
    // MARK: Properties
    
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Lifecycle
    
    override open func updateLayoutForBackgroundStyle(_ newStyle: BackgroundStyle, backgroundView: UIView?) {
        switch newStyle {
        case .blurDark:
            self.titleLabel?.textColor = UIColor.white
            self.actionButton?.setTitleColor(UIColor.lightText, for: UIControlState())
            self.activityIndicator?.color = UIColor.white
        default:
            self.titleLabel?.textColor = UIColor.black
            self.actionButton?.setTitleColor(self.tintColor, for: UIControlState())
            self.activityIndicator?.color = UIColor.darkGray
        }
    }
    
    open override func prepareLayoutForShowing() {
        super.prepareLayoutForShowing()
        
        self.stopLoading() // stop loading
    }

    // MARK: Public
    
    /**
     Display an activity indicator in place of the action button.
     */
    open func startLoading() {
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.isHidden = false
        self.actionButton?.isHidden = true
    }
    
    /**
     Hide the activity indicator.
     */
    open func stopLoading() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.isHidden = true
        self.actionButton?.isHidden = false
    }
}
