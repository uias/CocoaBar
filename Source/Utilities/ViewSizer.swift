//
//  ViewSizer.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 31/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

extension UIView {
    
    func requiredSizeWithWidth(requiredWidth: CGFloat?, requiredHeight: CGFloat?) -> CGSize {
        
        let width = requiredWidth == nil ? 0.0 : requiredWidth
        let height = requiredHeight == nil ? 0.0 : requiredHeight
        
        let horizontalPriority = (requiredWidth == nil) ? UILayoutPriorityDefaultLow : UILayoutPriorityRequired
        let verticalPriority = (requiredHeight == nil) ? UILayoutPriorityDefaultLow : UILayoutPriorityRequired
        
        return self.systemLayoutSizeFittingSize(CGSizeMake(width!, height!),
                                                    withHorizontalFittingPriority: horizontalPriority,
                                                    verticalFittingPriority: verticalPriority)
    }
}
