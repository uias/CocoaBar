//
//  BarStyle.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 06/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import Foundation

struct BarStyle: Any {
    
    var title: String
    var styleDescription: String
    
    var backgroundStyle: CocoaBarLayout.BackgroundStyle
    var barStyle: CocoaBar.Style?
    var layout: CocoaBarLayout?
    var duration: CocoaBar.DisplayDuration
    
    init(title: String,
         description: String,
         backgroundStyle: CocoaBarLayout.BackgroundStyle,
         barStyle:CocoaBar.Style,
         duration: CocoaBar.DisplayDuration) {
        
        self.title = title
        self.styleDescription = description
        self.backgroundStyle = backgroundStyle
        self.barStyle = barStyle
        self.duration = duration
    }
    
    init(title: String,
         description: String,
         backgroundStyle: CocoaBarLayout.BackgroundStyle,
         layout: CocoaBarLayout,
         duration: CocoaBar.DisplayDuration) {
        
        self.title = title
        self.styleDescription = description
        self.backgroundStyle = backgroundStyle
        self.layout = layout
        self.duration = duration
    }
}