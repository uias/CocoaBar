//
//  AutoLayoutUtils.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 31/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

internal extension UIView {
    
    @discardableResult internal func cb_autoPinToEdges() -> [NSLayoutConstraint]? {
        return self.cb_autoPinToEdges(UIEdgeInsets.zero)
    }
    
    @discardableResult internal func cb_autoPinToEdges(_ insets: UIEdgeInsets) -> [NSLayoutConstraint]? {
        if let views = self.setUpForAutoLayout() {
            
            let verticalConstraints = String(format: "V:|-(%f)-[view]-(%f)-|", insets.top, insets.bottom)
            let horizontalConstraints = String(format: "H:|-(%f)-[view]-(%f)-|", insets.left, insets.right)
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            self.superview?.addConstraints(constraints)
            
            return constraints
        }
        return nil
    }
    
    @discardableResult internal func cb_autoPinToSidesAndBottom() -> [NSLayoutConstraint]? {
        if let views = self.setUpForAutoLayout() {
        
            let verticalConstraints = "V:[view]|"
            let horizontalConstraints = "H:|[view]|"
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            self.superview?.addConstraints(constraints)
            
            return constraints
        }
        return nil
    }
    
    @discardableResult internal func cb_autoPinToSidesAndTop() -> [NSLayoutConstraint]? {
        if let views = self.setUpForAutoLayout() {
            
            let verticalConstraints = "V:|[view]"
            let horizontalConstraints = "H:|[view]|"
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            self.superview?.addConstraints(constraints)
            
            return constraints
        }
        
        return nil
    }
    
    @discardableResult internal func cb_autoPinToBottomAndCenter() -> [NSLayoutConstraint]? {
        if let views = self.setUpForAutoLayout() {
            
            let verticalConstraints = "V:[view]|"
            let centerHorizontalConstraints = "V:[superview]-(<=1)-[view]"
            
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: verticalConstraints,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views))
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: centerHorizontalConstraints,
                options: NSLayoutFormatOptions.alignAllCenterX,
                metrics: nil,
                views: views))
            
            self.superview?.addConstraints(constraints)
            
            return constraints
        }
        return nil
    }
    
    @discardableResult internal func cb_autoSetHeight(_ height: Float) -> NSLayoutConstraint? {
        if self.setUpForAutoLayout() != nil {
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: NSLayoutAttribute.height,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: nil,
                                                attribute: NSLayoutAttribute.notAnAttribute,
                                                multiplier: 1.0, constant: CGFloat(height))
            self.superview?.addConstraint(constraint)
            
            return constraint
        }
        return nil
    }
    
    @discardableResult internal func cb_autoSetWidth(_ width: Float) -> NSLayoutConstraint? {
        if self.setUpForAutoLayout() != nil {
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: NSLayoutAttribute.width,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: nil,
                                                attribute: NSLayoutAttribute.notAnAttribute,
                                                multiplier: 1.0, constant: CGFloat(width))
            self.superview?.addConstraint(constraint)
            
            return constraint
        }
        return nil
    }
    
    fileprivate func setUpForAutoLayout() -> [String: AnyObject]? {
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            return ["view" : self, "superview" : superview]
        }
        
        return nil
    }
}
