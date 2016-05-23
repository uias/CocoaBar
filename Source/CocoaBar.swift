//
//  CocoaBar.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout

// MARK: Notifications
private let CocoaBarShowNotification: String = "CocoaBarShowNotification"
private let CocoaBarHideNotification: String = "CocoaBarHideNotification"

class CocoaBar: UIView {
    
    // MARK: Defaults
    let cocoaBarDefaultHeight: Float = 50.0
    
    // MARK: Variables
    var height: Float
    private var displayWindow: UIWindow?
    
    // MARK: Init
    
    convenience init(window: UIWindow?) {
        self.init(window: window, height: nil)
    }
    
    init(window: UIWindow?, height: Float?) {
        
        if let height = height {
            self.height = height
        } else {
            self.height = self.cocoaBarDefaultHeight
        }
        
        self.displayWindow = window
        super.init(frame: CGRectZero)
        
        self.registerForNotifications()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        self.height = self.cocoaBarDefaultHeight
        
        super.init(coder: aDecoder)
        
        self.registerForNotifications()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private
    
    private func registerForNotifications() {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(showNotificationReceived), name: CocoaBarShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideNotificationReceived), name: CocoaBarHideNotification, object: nil)
    }
    
    private func setUpIfRequired() {
        if self.superview == nil {
            if let window = self.displayWindow {
                window.addSubview(self)
                
                self.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Top)
                self.autoSetDimension(ALDimension.Height, toSize: CGFloat(self.height))
            }
        }
    }
    
    // MARK: Public
    
    func show() {
        self.setUpIfRequired()
        
        
    }
    
    func hide() {
        
    }
    
    // MARK: Class
    
    class func show() {
        NSNotificationCenter.defaultCenter().postNotificationName(CocoaBarShowNotification, object: nil)
    }
    
    class func hide() {
        NSNotificationCenter.defaultCenter().postNotificationName(CocoaBarHideNotification, object: nil)
    }
    
    // MARK: Notifications
    
    @objc func showNotificationReceived(notification: NSNotification) {
        self.show()
    }
    
    @objc func hideNotificationReceived(notification: NSNotification) {
        self.hide()
    }
}
