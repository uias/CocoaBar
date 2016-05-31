//
//  CocoaBarErrorExpandedLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class CocoaBarErrorExpandedLayout: CocoaBarLayout {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func requiredHeight() -> Float {
        return 88.0
    }
}
