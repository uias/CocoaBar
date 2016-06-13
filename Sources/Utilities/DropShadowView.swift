//
//  DropShadowView.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 10/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public class DropShadowView: UIView {
    
    // MARK: Properties
    
    public var showDropShadow: Bool = false {
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
    }
    
    // MARK: Private
    
    private func updateShadow(enabled: Bool) {
        if enabled {
            self.layer.shadowOffset = CGSizeMake(0, 0)
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.6
        } else {
            self.layer.shadowOffset = CGSizeZero
            self.layer.shadowRadius = 0.0
            self.layer.shadowOpacity = 0.0
        }
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateShadow(self.showDropShadow)
    }
}
