//
//  GradientView.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 06/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // MARK: Variables
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: Properties
    
    var colors: [UIColor] = [UIColor.blackColor(), UIColor.whiteColor()] {
        didSet {
            self.updateGradient(self.colors)
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initGradient()
    }
    
    private func initGradient() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        self.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        
        self.updateGradient(self.colors)
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer?.frame = self.bounds
    }
    
    // MARK: Private
    
    func updateGradient(colors: [UIColor]) {
        var colorRefs: [CGColor] = []
        for color in colors {
            colorRefs.append(color.CGColor)
        }
        self.gradientLayer?.colors = colorRefs
    }
}
