//
//  CocoaBarTests.swift
//  CocoaBar Tests
//
//  Created by Merrick Sapsford on 29/06/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import XCTest

class CocoaBarTests: XCTestCase {
    
    var cocoaBar: CocoaBar!
    
    override func setUp() {
        super.setUp()
        
        let window = UIWindow(frame: CGRectMake(0, 0, 320, 568))
        self.cocoaBar = CocoaBar(window: window)
    }
    
    // MARK: State
    
    func testCocoaBarCanShow() {
        
        self.cocoaBar.showAnimated(false, duration: .Indeterminate, style: .Default, populate: nil, completion: nil)
        
        XCTAssertTrue(self.cocoaBar.isShowing)
        
        self.cocoaBar.hideAnimated(false, completion: nil)
    }
    
    func testCocoaBarCanHide() {
        
        self.cocoaBar.showAnimated(false, duration: .Indeterminate, style: .Default, populate: nil, completion: nil)
        self.cocoaBar.hideAnimated(false, completion: nil)
        
        XCTAssertFalse(self.cocoaBar.isShowing)
    }
    
    // MARK: Appearance
    
    func testCocoaBarStyleUpdate() {
        
        // change to action layout
        self.cocoaBar.showAnimated(false, duration: .Indeterminate, style: .Action, populate: nil, completion: nil)
        let actionLayout = self.cocoaBar.layout as? CocoaBarActionLayout
        let defaultLayout = self.cocoaBar.layout as? CocoaBarDefaultLayout
        
        XCTAssertNotNil(actionLayout)
        XCTAssertNil(defaultLayout)
    }
    
    func testCocoaBarCustomLayout() {
        
        let customLayout = CustomCocoaBarLayout()
        self.cocoaBar.showAnimated(false, duration: .Indeterminate, layout: customLayout, populate: nil, completion: nil)
        
        let customLayoutExists = (self.cocoaBar.layout as? CustomCocoaBarLayout) != nil
        
        XCTAssertTrue(customLayoutExists)
    }
    
    // MARK: KeyCocoaBar
    
    func testKeyCocoaBarAttachment() {
        
        let keyWindow = UIWindow(frame: CGRectMake(0, 0, 320, 568))
        keyWindow.makeKeyWindow()
        
        let keyCocoaBar = CocoaBar(window: keyWindow)
        
        XCTAssertEqual(keyCocoaBar, CocoaBar.keyCocoaBar)
    }
    
}
