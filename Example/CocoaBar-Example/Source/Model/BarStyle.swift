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
    var displayStyle: CocoaBarLayout.DisplayStyle
    var barStyle: CocoaBar.Style?
    var layout: CocoaBarLayout?
    var duration: CocoaBar.DisplayDuration
    
    init(title: String,
         description: String,
         backgroundStyle: CocoaBarLayout.BackgroundStyle,
         displayStyle: CocoaBarLayout.DisplayStyle,
         barStyle:CocoaBar.Style,
         duration: CocoaBar.DisplayDuration) {
        
        self.title = title
        self.styleDescription = description
        self.backgroundStyle = backgroundStyle
        self.displayStyle = displayStyle
        self.barStyle = barStyle
        self.duration = duration
    }
    
    init(title: String,
         description: String,
         backgroundStyle: CocoaBarLayout.BackgroundStyle,
         displayStyle: CocoaBarLayout.DisplayStyle,
         layout: CocoaBarLayout,
         duration: CocoaBar.DisplayDuration) {
        
        self.title = title
        self.styleDescription = description
        self.backgroundStyle = backgroundStyle
        self.displayStyle = displayStyle
        self.layout = layout
        self.duration = duration
    }
}