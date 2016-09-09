//
//  DropShadowView.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 10/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

/**
 A view that provides a drop shadow around its perimeter.
 */
open class DropShadowView: UIView {
    
    // MARK: Properties
    
    /**
     Whether to show the drop shadow (Default: false)
    */
    open var showDropShadow: Bool = false {
        didSet {
            self.updateShadow(self.showDropShadow)
        }
    }
    
    /**
     The opacity of the drop shadow (Default 0.7)
     */
    open var visibleOpacity: Float = 0.7 {
        didSet {
            self.updateShadow(self.showDropShadow)
        }
    }
    
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.baseInit()
    }
    
    fileprivate func baseInit() {
        
        self.layer.masksToBounds = false
        
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 8
    }
    
    // MARK: Private
    
    fileprivate func updateShadow(_ enabled: Bool) {
        self.layer.shadowOpacity = enabled ? self.visibleOpacity : 0.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
}
