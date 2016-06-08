//
//  AutoLayoutUtils.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 31/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

internal extension UIView {
    
    internal func autoPinToEdges() -> [NSLayoutConstraint] {
        let views = self.setUpForAutoLayout()
        
        let verticalConstraints = "V:|[view]|"
        let horizontalConstraints = "H:|[view]|"
        
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(horizontalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        self.superview?.addConstraints(constraints)
        
        return constraints
    }
    
    internal func autoPinToSidesAndBottom() -> [NSLayoutConstraint] {
        let views = self.setUpForAutoLayout()
        
        let verticalConstraints = "V:[view]|"
        let horizontalConstraints = "H:|[view]|"
        
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(horizontalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        self.superview?.addConstraints(constraints)
        
        return constraints
    }
    
    internal func autoPinToSidesAndTop() -> [NSLayoutConstraint] {
        let views = self.setUpForAutoLayout()
        
        let verticalConstraints = "V:|[view]"
        let horizontalConstraints = "H:|[view]|"
        
        var constraints = [NSLayoutConstraint]()
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(horizontalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(verticalConstraints,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views))
        self.superview?.addConstraints(constraints)
        
        return constraints
    }
    
    internal func autoSetHeight(height: Float) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: CGFloat(height))
        self.superview?.addConstraint(constraint)
        
        return constraint
    }
    
    private func setUpForAutoLayout() -> [String: AnyObject] {
        self.translatesAutoresizingMaskIntoConstraints = false
        let views = ["view" : self]
        return views
    }
}
