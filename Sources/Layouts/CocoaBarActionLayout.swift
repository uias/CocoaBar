//
//  CocoaBarActionLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 07/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public class CocoaBarActionLayout: CocoaBarLayout {
    
    // MARK: Properties
    
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Lifecycle
    
    override public func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
        switch newStyle {
        case .BlurDark:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.actionButton?.setTitleColor(UIColor.lightTextColor(), forState: UIControlState.Normal)
            self.activityIndicator?.color = UIColor.whiteColor()
        default:
            self.titleLabel?.textColor = UIColor.blackColor()
            self.actionButton?.setTitleColor(self.tintColor, forState: UIControlState.Normal)
            self.activityIndicator?.color = UIColor.darkGrayColor()
        }
    }
    
    public override func prepareLayoutForShowing() {
        super.prepareLayoutForShowing()
        
        self.stopLoading() // stop loading
    }

    // MARK: Public
    
    /**
     Display an activity indicator in place of the action button.
     */
    public func startLoading() {
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.hidden = false
        self.actionButton?.hidden = true
    }
    
    /**
     Hide the activity indicator.
     */
    public func stopLoading() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.hidden = true
        self.actionButton?.hidden = false
    }
}
