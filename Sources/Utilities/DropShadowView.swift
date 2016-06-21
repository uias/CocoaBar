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
public class DropShadowView: UIView {
    
    // MARK: Properties
    
    public var showDropShadow: Bool = false {
        didSet {
            self.updateShadow(self.showDropShadow)
        }
    }
    
    public var visibleOpacity: Float = 0.7 {
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
    
    private func baseInit() {
        
        self.layer.masksToBounds = false
        
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowRadius = 8
    }
    
    // MARK: Private
    
    private func updateShadow(enabled: Bool) {
        self.layer.shadowOpacity = enabled ? self.visibleOpacity : 0.0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
    }
}
