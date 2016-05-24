//
//  CocoaBar.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout

private let CocoaBarShowNotification: String = "CocoaBarShowNotification"
private let CocoaBarHideNotification: String = "CocoaBarHideNotification"

class CocoaBar: UIView, CocoaBarLayoutDelegate {
    
    enum BackgroundStyle {
        case SolidColor
        case BlurExtraLight
        case BlurLight
        case BlurDark
        case Custom
    }
    
    // MARK: Defaults
    let cocoaBarDefaultHeight: Float = 88.0
    
    // MARK: Variables
    private var height: Float
    private var rootWindow: UIWindow?
    
    private var backgroundViewContainer: UIView?
    private var layoutContainer: UIView?
    
    private var _backgroundView: UIView?
    
    private var _customLayout: CocoaBarLayout?
    private var _defaultLayout: CocoaBarLayout
    
    // MARK: Properties
    
    var backgroundStyle: BackgroundStyle = .BlurExtraLight {
        willSet {
            if newValue != self.backgroundStyle {
                self.updateBackgroundStyle(newValue)
            }
        }
    }
    
    var backgroundView: UIView? {
        get {
            return _backgroundView
        }
    }
    
    var layout: CocoaBarLayout {
        get {
            guard let customLayout = _customLayout else {
                return _defaultLayout
            }
            return customLayout
        }
        set {
            if _customLayout != newValue {
                _customLayout = newValue
                self.updateLayout(newValue)
            }
        }
    }
    
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
        
        self.rootWindow = window
        _defaultLayout = CocoaBarDefaultLayout()
        
        super.init(frame: CGRectZero)
        
        self.registerForNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.height = self.cocoaBarDefaultHeight
        _defaultLayout = CocoaBarDefaultLayout()

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
        
        notificationCenter.addObserver(self, selector: #selector(windowDidBecomeVisible), name: UIWindowDidBecomeVisibleNotification, object: nil)
    }
    
    private func setUpIfRequired() {
        if let rootWindow = self.rootWindow {
            if self.superview == nil {
                
                // add bar to display view controller
                rootWindow.addSubview(self)
                self.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Top)
                self.autoSetDimension(ALDimension.Height, toSize: CGFloat(self.height))
            }
        }
        
        // set up view components
        if self.backgroundViewContainer == nil {
            self.setUpComponents()
        }
    }
    
    private func setUpComponents() {
        
        // add background view container
        let backgroundViewContainer = UIView()
        self.addSubview(backgroundViewContainer)
        backgroundViewContainer.autoPinEdgesToSuperviewEdges()
        self.backgroundViewContainer = backgroundViewContainer
        self.updateBackgroundStyle(self.backgroundStyle)
        
        let layoutContainer = UIView()
        self.addSubview(layoutContainer)
        layoutContainer.autoPinEdgesToSuperviewEdges()
        self.layoutContainer = layoutContainer
        self.updateLayout(self.layout)
    }
    
    private func bringBarToFront() {
        if let rootWindow = self.rootWindow {
            rootWindow.bringSubviewToFront(self)
        }
    }
    
    private func updateBackgroundStyle(newStyle: BackgroundStyle) {
        if let backgroundViewContainer = self.backgroundViewContainer {
            
            // clear subviews
            for view in backgroundViewContainer.subviews{
                view.removeFromSuperview()
            }
            _backgroundView = nil
            
            switch newStyle {
                
            case .BlurExtraLight, .BlurLight, .BlurDark:
                self.backgroundViewContainer?.backgroundColor = UIColor.clearColor()
                
                var style: UIBlurEffectStyle
                switch newStyle {
                case .BlurExtraLight: style = UIBlurEffectStyle.ExtraLight
                case .BlurDark: style = UIBlurEffectStyle.Dark
                default: style = UIBlurEffectStyle.Light
                }
                
                // add blur view
                let blurEffect = UIBlurEffect(style: style)
                let visualEffectView = UIVisualEffectView(effect: blurEffect)
                
                self.backgroundViewContainer?.addSubview(visualEffectView)
                visualEffectView.autoPinEdgesToSuperviewEdges()
                
            case .Custom:
                
                // create custom background view
                let backgroundView = UIView()
                backgroundViewContainer.addSubview(backgroundView)
                backgroundView.autoPinEdgesToSuperviewEdges()
                _backgroundView = backgroundView
                
            default:()
            }
        }
    }
    
    private func updateLayout(layout: CocoaBarLayout) {
        if let layoutContainer = self.layoutContainer {
            
            // clear layout container
            for view in layoutContainer.subviews {
                view.removeFromSuperview()
            }
            
            layout.delegate = self
            layoutContainer.addSubview(layout)
            layout.autoPinEdgesToSuperviewEdges()
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
    
    @objc func windowDidBecomeVisible(notification: NSNotification) {
        self.bringBarToFront()
    }
    
    // MARK: CocoaBarLayoutDelegate
    
    func cocoaBarLayoutDismissButtonPressed(dismissButton: UIButton?) {
        
    }
    
    func cocoaBarLayoutActionButtonPressed(actionButton: UIButton?) {
        
    }
}
