//
//  DropShadowView.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 10/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

internal class DropShadowView: UIView {
    
    // MARK: Variables
    
    private var shadowLayer = CAGradientLayer()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.baseInit()
    }
    
    private func baseInit() {
        
        shadowLayer.frame = self.bounds
        shadowLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        self.layer.addSublayer(shadowLayer)
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.frame = self.bounds
    }
}
