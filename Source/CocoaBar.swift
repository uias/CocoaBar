//
//  CocoaBar.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout

private let CocoaBarHideNotification: String =  "CocoaBarHideNotification"
private let CocoaBarAnimatedKey: String =       "animated"

typealias CocoaBarPopulationClosure = (layout: CocoaBarLayout) -> Void
typealias CocoaBarAnimationCompletionClosure = (animated: Bool, completed: Bool, visible: Bool) -> Void

enum DisplayDuration: Double {
    case Short = 2.0
    case Long = 4.0
    case ExtraLong = 6.0
}

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
    private var bottomMarginConstraint: NSLayoutConstraint?
    
    private var backgroundViewContainer: UIView?
    private var layoutContainer: UIView?
    
    private var _backgroundView: UIView?
    
    private var _customLayout: CocoaBarLayout?
    private var _defaultLayout: CocoaBarLayout
    
    private var isAnimating: Bool = false
    
    private var displayTimer: NSTimer?
    
    private static var keyCocoaBar: CocoaBar?
    
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
            if (_customLayout != newValue) && (newValue != _defaultLayout) {
                _customLayout = newValue
                self.updateLayout(newValue)
            }
        }
    }
    
    private(set) var isShowing: Bool = false
    
    var tapToDismiss: Bool = false
    
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
        
        // set key bar to the one initialised on key window
        if let window = window {
            if window.keyWindow == true {
                CocoaBar.keyCocoaBar = self
            }
        }
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
    
    // MARK: Lifecycle
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        // hide if tap to dismiss enabled
        let point = self.convertPoint(point, toView: self)
        if self.isShowing && CGRectContainsPoint(self.bounds, point) && tapToDismiss {
            self.hideAnimated(true, completion: nil)
        }
        return hitView
    }
    
    // MARK: Private
    
    private func registerForNotifications() {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(hideNotificationReceived), name: CocoaBarHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(windowDidBecomeVisible), name: UIWindowDidBecomeVisibleNotification, object: nil)
    }
    
    private func setUpIfRequired() {
        if let rootWindow = self.rootWindow {
            if self.superview == nil {
                
                // add bar to display view controller
                rootWindow.addSubview(self)
                let constraints = self.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Top)
                self.autoSetDimension(ALDimension.Height, toSize: CGFloat(self.height))
                
                self.bottomMarginConstraint = constraints[1]
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
    
    private func setUpDisplayTimer(duration: Double) {
        if self.displayTimer == nil {
            self.displayTimer = NSTimer.scheduledTimerWithTimeInterval(duration,
                                                                       target: self,
                                                                       selector: #selector(displayTimerElapsed),
                                                                       userInfo: nil,
                                                                       repeats: false)
        }
    }
    
    private func destroyDisplayTimer() {
        if let displayTimer = self.displayTimer {
            displayTimer.invalidate()
            self.displayTimer = nil
        }
    }
    
    @objc private func displayTimerElapsed(timer: NSTimer?) {
        self.destroyDisplayTimer()
        self.hideAnimated(true, completion: nil)
    }
    
    // MARK: Public
    
    func showAnimated(animated: Bool,
                      duration: DisplayDuration,
                      layout: CocoaBarLayout?,
                      populate: CocoaBarPopulationClosure?,
                      completion: CocoaBarAnimationCompletionClosure?) {
        
        self.showAnimated(animated,
                          duration: duration.rawValue,
                          layout: layout,
                          populate: populate,
                          completion: completion)
    }
    
    func showAnimated(animated: Bool,
                      duration: Double,
                      layout: CocoaBarLayout?,
                      populate: CocoaBarPopulationClosure?,
                      completion: CocoaBarAnimationCompletionClosure?) {
        
        if !self.isShowing {
            self.setUpIfRequired()
            self.bringBarToFront()
            if let layout = layout {
                self.layout = layout
            }
            
            if let populate = populate {
                populate(layout: self.layout)
            }
            
            if animated { // animate in
                if !self.isAnimating {
                    
                    self.bottomMarginConstraint?.constant = 0.0
                    self.isAnimating = true
                    UIView.animateWithDuration(0.2,
                                               delay: 0.0,
                                               options: UIViewAnimationOptions.CurveEaseOut,
                                               animations:
                        {
                            self.layoutIfNeeded()
                        },
                                               completion:
                        { (completed) in
                            self.isShowing = true
                            self.isAnimating = false
                            self.setUpDisplayTimer(duration)
                            
                            if let completion = completion {
                                completion(animated: animated, completed: completed, visible: self.isShowing)
                            }
                        }
                    )
                }
            } else {
                
                self.bottomMarginConstraint?.constant = 0.0
                self.layoutIfNeeded()
                self.isShowing = true
                self.setUpDisplayTimer(duration)
                
                if let completion = completion {
                    completion(animated: animated, completed: true, visible: self.isShowing)
                }
            }
        }
    }
    
    func hideAnimated(animated: Bool,
                      completion: CocoaBarAnimationCompletionClosure?) {
        
        if self.isShowing && !self.isAnimating {
            self.destroyDisplayTimer()
            
            if animated {
                if !self.isAnimating { // animate out
                    
                    self.bottomMarginConstraint?.constant = self.bounds.size.height
                    self.isAnimating = true
                    UIView.animateWithDuration(0.2,
                                               delay: 0.0,
                                               options: UIViewAnimationOptions.CurveEaseIn,
                                               animations:
                        {
                            self.layoutIfNeeded()
                        },
                                               completion:
                        { (completed) in
                            self.isShowing = false
                            self.isAnimating = false
                            
                            if let completion = completion {
                                completion(animated: animated, completed: completed, visible: self.isShowing)
                            }
                        }
                    )
                }
            } else {
                
                self.bottomMarginConstraint?.constant = self.bounds.size.height
                self.layoutIfNeeded()
                self.isShowing = false
                
                if let completion = completion {
                    completion(animated: animated, completed: true, visible: self.isShowing)
                }
            }
        }
    }
    
    // MARK: Class
    
    class func showAnimated(animated: Bool,
                            duration: DisplayDuration,
                            layout: CocoaBarLayout?,
                            populate: CocoaBarPopulationClosure?,
                            completion: CocoaBarAnimationCompletionClosure?) {
        
        CocoaBar.showAnimated(animated,
                              duration: duration.rawValue,
                              layout: layout,
                              populate: populate,
                              completion: completion)
    }
    
    class func showAnimated(animated: Bool,
                            duration: Double,
                            layout: CocoaBarLayout?,
                            populate: CocoaBarPopulationClosure?,
                            completion: CocoaBarAnimationCompletionClosure?) {
        
        if let keyBar = self.keyCocoaBar {
            keyBar.showAnimated(animated,
                                duration: duration,
                                layout: layout,
                                populate: populate,
                                completion: completion)
        } else {
            print("Could not show as no CocoaBar is currently attached to the keyWindow")
        }
    }
    
    class func hide(animated: Bool,
                    completion: CocoaBarAnimationCompletionClosure?) {
        
        if let keyBar = self.keyCocoaBar {
            keyBar.hideAnimated(animated,
                                completion: completion)
        } else {
            print("Could not hide as no CocoaBar is currently attached to the keyWindow")
        }
    }
    
    // MARK: Notifications
    
    @objc func hideNotificationReceived(notification: NSNotification) {
        var animated = true
        if let userInfo = notification.userInfo {
            animated = userInfo[CocoaBarAnimatedKey] as! Bool
        }
        self.hideAnimated(animated, completion: nil)
    }
    
    @objc func windowDidBecomeVisible(notification: NSNotification) {
        self.bringBarToFront()
    }
    
    // MARK: CocoaBarLayoutDelegate
    
    func cocoaBarLayoutDismissButtonPressed(dismissButton: UIButton?) {
        self.hideAnimated(true, completion: nil)
    }
    
    func cocoaBarLayoutActionButtonPressed(actionButton: UIButton?) {
        
    }
}
