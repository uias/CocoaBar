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
    
    fileprivate var gradientLayer: CAGradientLayer?
    
    // MARK: Properties
    
    var colors: [UIColor] = [UIColor.black, UIColor.white] {
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
    
    fileprivate func initGradient() {
        
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
    
    func updateGradient(_ colors: [UIColor]) {
        var colorRefs: [CGColor] = []
        for color in colors {
            colorRefs.append(color.cgColor)
        }
        self.gradientLayer?.colors = colorRefs
    }
}
