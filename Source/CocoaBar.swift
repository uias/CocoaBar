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

public typealias CocoaBarPopulationClosure = (layout: CocoaBarLayout) -> Void
public typealias CocoaBarAnimationCompletionClosure = (animated: Bool, completed: Bool, visible: Bool) -> Void

public protocol CocoaBarDelegate: Any {
    
    /**
     The action button on the CocoaBar has been pressed.
     
     :param: cocoaBar       The CocoaBar that contains the action button.
     :param: actionButton   The action button that was pressed.
     
     */
    func cocoaBar(cocoaBar: CocoaBar, actionButtonPressed actionButton: UIButton?)
    /**
     The CocoaBar will show.
     
     :param: cocoaBar       The CocoaBar that will show.
     :param: animated       Whether the show transition will be animated.
     
     */
    func cocoaBar(cocoaBar: CocoaBar, willShowAnimated animated: Bool)
    /**
     The CocoaBar has shown.
     
     :param: cocoaBar       The CocoaBar that has shown.
     :param: animated       Whether the show transition was animated.
     
     */
    func cocoaBar(cocoaBar: CocoaBar, didShowAnimated animated: Bool)
    /**
     The CocoaBar will hide.
     
     :param: cocoaBar       The CocoaBar that will hide.
     :param: animated       Whether the hide transition will be animated.
     
     */
    func cocoaBar(cocoaBar: CocoaBar, willHideAnimated animated: Bool)
    /**
     The CocoaBar has hidden.
     
     :param: cocoaBar       The CocoaBar that has become hidden.
     :param: animated       Whether the hide transition was animated.
     
     */
    func cocoaBar(cocoaBar: CocoaBar, didHideAnimated animated: Bool)
}

public class CocoaBar: UIView, CocoaBarLayoutDelegate {
    
    /**
     The duration to display the CocoaBar for when shown.
     */
    public enum DisplayDuration {
        
        /**
         Display the bar for 2 seconds before auto-dismissal.
         */
        case Short
        /**
         Display the bar for 4 seconds before auto-dismissal.
         */
        case Long
        /**
         Display the bar for 8 seconds before auto-dismissal.
         */
        case ExtraLong
        /**
         Display the bar indeterminately.
         */
        case Indeterminate
        
        var value: Double {
            switch self {
            case .Short:
                return 2.0
            case .Long:
                return 4.0
            case .ExtraLong:
                return 8.0
                
            default:
                return DBL_MAX
            }
        }
    }
    
    /**
     The style of the CocoaBar
     */
    public enum Style {
        
        /**
         Default style - text label with no buttons.
         */
        case Default
        /**
         Action style - text label with right side action button.
        */
        case Action
    }
    
    // MARK: Variables
    
    private var displayWindow: UIWindow?
    private var displayView: UIView?

    private var bottomMarginConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var layoutContainer: UIView?
    
    private var _customLayout: CocoaBarLayout?
    private var _defaultLayout: CocoaBarLayout = CocoaBarDefaultLayout()
    
    private var isAnimating: Bool = false
    
    private var displayTimer: NSTimer?
    
    // MARK: Properties
    
    /**
     The layout for the Cocoabar to use when displaying. The bar will use 
     CocoaBarDefaultLayout if a custom layout is not specified.
     */
    public var layout: CocoaBarLayout {
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
    
    /**
     Whether the CocoaBar is currently showing
     */
    public private(set) var isShowing: Bool = false
    
    /**
     Whether the CocoaBar has tap to dismiss enabled. If enabled, the CocoaBar
     will dismiss when tapped while it is showing.
     */
    public var tapToDismiss: Bool = false
    
    /**
     The object that acts as a delegate to the CocoaBar
     */
    public var delegate: CocoaBarDelegate?
    
    /**
     The CocoaBar that is attached to the key window.
     */
    public private(set) static var keyCocoaBar: CocoaBar?
    
    // MARK: Init
    
    /**
     Create a new instance of a CocoaBar that will display from a window. Using 
     the keyWindow will set the instance to the keyCocoaBar for access from class
     methods.
     */
    public init(window: UIWindow?) {
        
        self.displayWindow = window
        
        super.init(frame: CGRectZero)
        
        // set key bar to the one initialised on key window
        if let window = window {
            
            // if keyCocoaBar does not exist - assume that this is key window
            if CocoaBar.keyCocoaBar == nil {
                window.becomeKeyWindow()
            }
            
            if window.keyWindow == true {
                CocoaBar.keyCocoaBar = self
            }
        }
        self.registerForNotifications()
    }
    
    /**
     Create a new instance of a CocoaBar that will display from a view.
     */
    public init(view: UIView?) {
        
        self.displayView = view
        
        super.init(frame: CGRectZero)
        
        self.registerForNotifications()
    }
    
    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        self.registerForNotifications()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Lifecycle
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
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
        if let displayWindow = self.displayWindow { // if we have a display window
            if self.superview == nil {
                
                // add bar to display window
                displayWindow.addSubview(self)
                self.setUpConstraints()
            }
        } else if let displayView = self.displayView { // fallback to displaying from view
            if self.superview == nil {
                
                displayView.addSubview(self)
                self.setUpConstraints()
            }
        }
        
        // set up view components
        if self.layoutContainer == nil {
            self.setUpComponents()
        }
    }
    
    private func setUpConstraints() {
        let constraints = self.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Top)
        self.heightConstraint = self.autoSetDimension(ALDimension.Height, toSize: CGFloat(0.0))
        self.heightConstraint?.active = false
        self.bottomMarginConstraint = constraints[1]
    }
    
    private func setUpComponents() {
        
        // set up layout container
        let layoutContainer = UIView()
        self.addSubview(layoutContainer)
        layoutContainer.autoPinEdgesToSuperviewEdges()
        self.layoutContainer = layoutContainer
        self.updateLayout(self.layout)
    }
    
    private func bringBarToFront() {
        if let displayWindow = self.displayWindow {
            displayWindow.bringSubviewToFront(self)
        }
    }
    
    private func updateLayout(layout: CocoaBarLayout) {
        if let layoutContainer = self.layoutContainer {
            
            // clear layout container
            for view in layoutContainer.subviews {
                view.removeFromSuperview()
            }
            
            // update height if required
            let requiresHeightConstraint = (layout.height != nil)
            self.heightConstraint?.active = requiresHeightConstraint
            if requiresHeightConstraint {
                self.heightConstraint?.constant = CGFloat(layout.height!)
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
    
    private func layoutForStyle(style: Style?) -> CocoaBarLayout? {
        if let style = style {
            
            var layout: CocoaBarLayout
            switch style {
                
            case .Action:
                layout = CocoaBarActionLayout()
                break
                
            default:
                layout = CocoaBarDefaultLayout()
                break
            }
            return layout
        }
        return nil
    }
    
    private func doShowAnimated(animated: Bool,
                                duration: Double,
                                layout: CocoaBarLayout?,
                                populate: CocoaBarPopulationClosure?,
                                completion: CocoaBarAnimationCompletionClosure?) {
        if !self.isShowing {
            
            // update layout
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
                    
                    if let delegate = self.delegate {
                        delegate.cocoaBar(self, willShowAnimated: animated)
                    }
                    
                    // hide layout offscreen initially
                    self.layout.layoutIfNeeded()
                    self.bottomMarginConstraint?.constant = (self.layout.height != nil) ? CGFloat(self.layout.height!) : self.layout.bounds.size.height
                    
                    self.layoutIfNeeded()
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
                            
                            if let delegate = self.delegate {
                                delegate.cocoaBar(self, didShowAnimated: animated)
                            }
                            if let completion = completion {
                                completion(animated: animated, completed: completed, visible: self.isShowing)
                            }
                        }
                    )
                }
            } else {
                
                if let delegate = self.delegate {
                    delegate.cocoaBar(self, willShowAnimated: animated)
                }
                
                self.bottomMarginConstraint?.constant = 0.0
                self.layoutIfNeeded()
                self.isShowing = true
                self.setUpDisplayTimer(duration)
                
                if let completion = completion {
                    completion(animated: animated, completed: true, visible: self.isShowing)
                }
                if let delegate = self.delegate {
                    delegate.cocoaBar(self, didShowAnimated: animated)
                }
            }
        }
    }
    
    private func doHideAnimated(animated: Bool,
                                completion: CocoaBarAnimationCompletionClosure?) {
        if self.isShowing && !self.isAnimating {
            self.destroyDisplayTimer()
            
            if animated {
                if !self.isAnimating { // animate out
                    
                    if let delegate = self.delegate {
                        delegate.cocoaBar(self, willHideAnimated: animated)
                    }
                    
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
                            
                            if let delegate = self.delegate {
                                delegate.cocoaBar(self, didHideAnimated: animated)
                            }
                            if let completion = completion {
                                completion(animated: animated, completed: completed, visible: self.isShowing)
                            }
                        }
                    )
                }
            } else {
                
                if let delegate = self.delegate {
                    delegate.cocoaBar(self, willHideAnimated: animated)
                }
                
                self.bottomMarginConstraint?.constant = self.bounds.size.height
                self.layoutIfNeeded()
                self.isShowing = false
                
                if let completion = completion {
                    completion(animated: animated, completed: true, visible: self.isShowing)
                }
                if let delegate = self.delegate {
                    delegate.cocoaBar(self, didHideAnimated: animated)
                }
            }
        }

    }
    
    // MARK: Public
    
    /**
     Shows the CocoaBar
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The duration to display the bar for (DisplayDuration enum).
     :param: layout         The layout to use for the bar. Using nil will keep the existing layout.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public func showAnimated(animated: Bool,
                             duration: DisplayDuration,
                             layout: CocoaBarLayout?,
                             populate: CocoaBarPopulationClosure?,
                             completion: CocoaBarAnimationCompletionClosure?) {
        
        self.showAnimated(animated,
                          duration: duration.value,
                          layout: layout,
                          populate: populate,
                          completion: completion)
    }
    
    /**
     Shows the CocoaBar
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The duration to display the bar for (DisplayDuration enum).
     :param: style          The style to use for the bar. Using nil will use the existing style.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public func showAnimated(animated: Bool,
                             duration: DisplayDuration,
                             style: Style?,
                             populate: CocoaBarPopulationClosure?,
                             completion: CocoaBarAnimationCompletionClosure?) {
        
        self.showAnimated(animated,
                          duration: duration,
                          layout: self.layoutForStyle(style),
                          populate: populate,
                          completion: completion)
    }
    
    /**
     Shows the CocoaBar
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The exact duration to display the bar for (Double).
     :param: layout         The layout to use for the bar. Using nil will keep the existing layout.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public func showAnimated(animated: Bool,
                             duration: Double,
                             layout: CocoaBarLayout?,
                             populate: CocoaBarPopulationClosure?,
                             completion: CocoaBarAnimationCompletionClosure?) {
        self.doShowAnimated(animated,
                            duration: duration,
                            layout: layout,
                            populate: populate,
                            completion: completion)
    }
    
    /**
     Shows the CocoaBar
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The exact duration to display the bar for (Double).
     :param: style          The style to use for the bar. Using nil will use the existing style.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public func showAnimated(animated: Bool,
                             duration: Double,
                             style: Style?,
                             populate: CocoaBarPopulationClosure?,
                             completion: CocoaBarAnimationCompletionClosure?) {
        
        self.showAnimated(animated,
                          duration: duration,
                          layout: self.layoutForStyle(style),
                          populate: populate,
                          completion: completion)
    }
    
    /**
     Hides the CocoaBar
     
     :param: animated       Whether to animate hiding the bar.
     :param: completion     Closure for completion of the hide transition.
     
     */
    public func hideAnimated(animated: Bool,
                             completion: CocoaBarAnimationCompletionClosure?) {
        self.doHideAnimated(animated,
                            completion: completion)
    }
    
    // MARK: Class
    
    /**
     Shows the keyCocoaBar if it exists. The keyCocoaBar is the CocoaBar attached to the keyWindow.
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The duration to display the bar for (DisplayDuration enum).
     :param: layout         The layout to use for the bar. Using nil will keep the existing layout.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public class func showAnimated(animated: Bool,
                                   duration: DisplayDuration,
                                   layout: CocoaBarLayout?,
                                   populate: CocoaBarPopulationClosure?,
                                   completion: CocoaBarAnimationCompletionClosure?) {
        
        CocoaBar.showAnimated(animated,
                              duration: duration.value,
                              layout: layout,
                              populate: populate,
                              completion: completion)
    }
    
    /**
     Shows the keyCocoaBar if it exists. The keyCocoaBar is the CocoaBar attached to the keyWindow.
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The duration to display the bar for (DisplayDuration enum).
     :param: style          The style to use for the bar. Using nil will use the existing style.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public class func showAnimated(animated: Bool,
                                   duration: DisplayDuration,
                                   style: Style?,
                                   populate: CocoaBarPopulationClosure?,
                                   completion: CocoaBarAnimationCompletionClosure?) {
        CocoaBar.showAnimated(animated,
                              duration: duration,
                              layout: CocoaBar.keyCocoaBar?.layoutForStyle(style),
                              populate: populate,
                              completion: completion)
    }
    
    /**
     Shows the keyCocoaBar if it exists. The keyCocoaBar is the CocoaBar attached to the keyWindow.
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The exact duration to display the bar for (Double).
     :param: layout         The layout to use for the bar. Using nil will keep the existing layout.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public class func showAnimated(animated: Bool,
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
    
    /**
     Shows the keyCocoaBar if it exists. The keyCocoaBar is the CocoaBar attached to the keyWindow.
     
     :param: animated       Whether to animate showing the bar.
     :param: duration       The exact duration to display the bar for (Double).
     :param: style          The style to use for the bar. Using nil will use the existing style.
     :param: populate       Closure to populate the layout with data.
     :param: completion     Closure for completion of the show transition.
     
     */
    public class func showAnimated(animated: Bool,
                                   duration: Double,
                                   style: Style?,
                                   populate: CocoaBarPopulationClosure?,
                                   completion: CocoaBarAnimationCompletionClosure?) {
        
        CocoaBar.showAnimated(animated,
                              duration: duration,
                              layout: CocoaBar.keyCocoaBar?.layoutForStyle(style),
                              populate: populate,
                              completion: completion)
    }
    
    /**
     Hides the keyCocoaBar if it exists. The keyCocoaBar is the CocoaBar attached to the keyWindow.
     
     :param: animated       Whether to animate hiding the bar.
     :param: completion     Closure for completion of the hide transition.
     
     */
    public class func hideAnimated(animated: Bool,
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
        if let delegate = self.delegate {
            delegate.cocoaBar(self, actionButtonPressed: actionButton)
        }
    }
}
