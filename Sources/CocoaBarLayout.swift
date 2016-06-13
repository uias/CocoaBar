//
//  CocoaBarLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

public class CocoaBarLayout: UIView {
    
    /**
     BackgroundStyle dictates the appearance of the background view
     in the layout.
     */
    public enum BackgroundStyle {
        /**
         SolidColor relies on setting the backgroundColor property of the layout.
         */
        case SolidColor
        /**
         BlurExtraLight displays a blur view with UIBlurEffectStyle.ExtraLight
         */
        case BlurExtraLight
        /**
         BlurLight displays a blur view with UIBlurEffectStyle.Light
         */
        case BlurLight
        /**
         BlurDark displays a blur view with UIBlurEffectStyle.Dark
         */
        case BlurDark
        /**
         Custom provides a UIView to the backgroundView property for enhanced
         customisation.
         */
        case Custom
    }
    
    // MARK: Defaults
    
    public let CocoaBarLayoutDefaultKeylineColor: UIColor = UIColor.lightGrayColor()
    public let CocoaBarLayoutDefaultKeylineColorDark: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    
    // MARK: Constants
    
    internal let CocoaBarLayoutDropShadowHeight: Float = 24.0
    
    // MARK: Variables
    
    private var isShown: Bool = false
    
    private var customNibName: String?
    private var nibView: UIView?
    
    private var backgroundContainer: UIView?
    
    private var keylineView: UIView?
    private var customKeylineColor: UIColor?
    
    private var dropShadowContainer: UIView?
    private var dropShadowView: DropShadowView?
    
    private var nibName: String {
        get {
            guard let nibName = customNibName else {
                return String(self.classForCoder)
            }
            return nibName
        }
        set {
            customNibName = newValue
        }
    }
    
    // MARK: Properties
    
    /**
     The object that acts as a delegate to the layout.
     This should always be the CocoaBar
    */
    internal var delegate: CocoaBarLayoutDelegate?
    
    /**
     The dismiss button on the layout
     */
    @IBOutlet weak var dismissButton: UIButton? {
        willSet {
            if let dismissButton = newValue {
                dismissButton.addTarget(self,
                                        action: #selector(closeButtonPressed),
                                        forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
    /**
     The action button on the layout
     */
    @IBOutlet weak var actionButton: UIButton? {
        willSet {
            if let actionButton = newValue {
                actionButton.addTarget(self,
                                        action: #selector(actionButtonPressed),
                                        forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
    /**
     The background style to use for the layout. Defaults to BlurExtraLight.
     */
    public var backgroundStyle: BackgroundStyle = .BlurExtraLight {
        didSet {
            self.updateBackgroundStyle(self.backgroundStyle)
        }
    }
    
    /**
     The background view in the layout. This is only available when using .Custom
     for the backgroundStyle.
     */
    public private(set) var backgroundView: UIView?
    
    /**
     The height required for the layout. Uses CocoaBarLayoutDefaultHeight if custom
     height not specified.
     */
    public private(set) var height: Float?
    
    /**
     The color of the keyline at the top of the layout.
     */
    public var keylineColor: UIColor {
        get {
            guard let keylineColor = customKeylineColor else {
                switch self.backgroundStyle {
                case .BlurDark:
                    return CocoaBarLayoutDefaultKeylineColorDark
                default:
                    return CocoaBarLayoutDefaultKeylineColor

                }
            }
            return keylineColor
        }
        set (newColor) {
            customKeylineColor = newColor
            self.keylineView?.backgroundColor = newColor
        }
    }
    
    /**
     Whether to display a drop shadow at the top of the layout.
     */
    public var showDropShadow: Bool = false {
        didSet {
            self.updateDropShadow(self.showDropShadow)
        }
    }
    
    // MARK: Init
    
    /**
     Create a new instance of a CocoaBarLayout. This will use the default nibName
     equal to the class name.
     */
    convenience public init() {
        self.init(nibName: nil, height: nil)
    }
    
    /**
     Create a new instance of a CocoaBarLayout with a specific nib name.
     
     :param: nibName    The name of the nib to inflate for the layout.
    */
    public init(nibName: String?, height: Float?) {
        self.customNibName = nibName
        
        super.init(frame: CGRectZero)
        
        self.setUpBackgroundView()
        self.setUpNibView()
        self.setUpAppearance()
        
        if let height = height {
            self.height = height
        } else if self.requiredHeight() > 0 {
            self.height = self.requiredHeight()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setUpBackgroundView()
        self.setUpNibView()
    }

    // MARK: Private
    
    private func setUpBackgroundView() {
        
        let dropShadowContainer = UIView()
        self.addSubview(dropShadowContainer)
        dropShadowContainer.autoPinToEdges(UIEdgeInsets(top: -CGFloat(CocoaBarLayoutDropShadowHeight), left: 0.0, bottom: 0.0, right: 0.0))
        self.dropShadowContainer = dropShadowContainer
        
        let dropShadowView = DropShadowView()
        dropShadowContainer.addSubview(dropShadowView)
        dropShadowView.autoPinToSidesAndTop()
        dropShadowView.autoSetHeight(CocoaBarLayoutDropShadowHeight)
        dropShadowView.alpha = 0.0
        self.dropShadowView = dropShadowView
        
        let backgroundContainer = UIView()
        self.addSubview(backgroundContainer)
        backgroundContainer.autoPinToEdges()
        self.backgroundContainer = backgroundContainer
        
        let keylineView = UIView()
        self.addSubview(keylineView)
        keylineView.autoPinToSidesAndTop()
        keylineView.autoSetHeight(1.0)
        self.keylineView = keylineView
    }
    
    private func setUpNibView() {
        
        // check if nib exists
        let bundle = NSBundle(forClass: self.classForCoder)
        if bundle.pathForResource(self.nibName, ofType: "nib") != nil {
            
            let nib = UINib(nibName: self.nibName, bundle: bundle)
            let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
            self.nibView = view
            
            self.addSubview(view)
            view.autoPinToEdges()
            
            // view is transparent
            view.backgroundColor = UIColor.clearColor()
        }
    }
    
    private func setUpAppearance() {
        
        self.keylineView?.backgroundColor = self.keylineColor
        
        self.updateBackgroundStyle(self.backgroundStyle)
    }
    
    private func updateBackgroundStyle(newStyle: BackgroundStyle) {
        if let backgroundContainer = self.backgroundContainer {
            
            // clear subviews
            for view in backgroundContainer.subviews{
                view.removeFromSuperview()
            }
            self.backgroundView = nil
            
            switch newStyle {
                
            case .BlurExtraLight, .BlurLight, .BlurDark:
                self.backgroundColor = UIColor.clearColor()
                
                var style: UIBlurEffectStyle
                switch newStyle {
                case .BlurExtraLight: style = UIBlurEffectStyle.ExtraLight
                case .BlurDark: style = UIBlurEffectStyle.Dark
                default: style = UIBlurEffectStyle.Light
                }
                
                // add blur view
                let blurEffect = UIBlurEffect(style: style)
                let visualEffectView = UIVisualEffectView(effect: blurEffect)
                
                backgroundContainer.addSubview(visualEffectView)
                visualEffectView.autoPinToEdges()
                
            case .Custom:
                self.backgroundColor = UIColor.clearColor()
                
                // create custom background view
                let backgroundView = UIView()
                backgroundContainer.addSubview(backgroundView)
                backgroundView.autoPinToEdges()
                self.backgroundView = backgroundView
                
            default:()
            }
            
            self.keylineView?.backgroundColor = self.keylineColor
            self.updateLayoutForBackgroundStyle(newStyle, backgroundView: self.backgroundView)
        }
    }
    
    private func updateDropShadow(visible: Bool) {
        if visible && self.isShown {
            self.dropShadowView?.alpha = 1.0
        } else {
            self.dropShadowView?.alpha = 0.0
        }
    }
    
    // MARK: Public
    
    /**
     The height required for the bar layout. Override this to manually specify a
     height for the cocoa bar layout.
     */
    public func requiredHeight() -> Float {
        return 0
    }
    
    /**
     Update the layout when the background style changes.
     
     :param: newStyle           The new background style.
     :param: backgroundView     The custom background view (only available when
     using .Custom backgroundStyle).
     */
    public func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
        
    }
    
    // MARK: Internal
    
    internal func updateLayoutForShowing() {
        self.isShown = true
        if self.showDropShadow {
            self.dropShadowView?.alpha = 1.0
        }
    }
    
    internal func updateLayoutForHiding() {
        self.isShown = false
        if self.showDropShadow {
            self.dropShadowView?.alpha = 0.0
        }
    }
    
    // MARK: Interaction
    
    @objc func closeButtonPressed(sender: UIButton?) {
        if let delegate = self.delegate {
            delegate.cocoaBarLayoutDismissButtonPressed(sender)
        }
    }
    
    @objc func actionButtonPressed(sender: UIButton?) {
        if let delegate = self.delegate {
            delegate.cocoaBarLayoutActionButtonPressed(sender)
        }
    }
}

internal protocol CocoaBarLayoutDelegate: Any {
    
    /**
     The dismiss button has been pressed on the layout.
     
     :param: dismissButton  The dismiss button.
     */
    func cocoaBarLayoutDismissButtonPressed(dismissButton: UIButton?)
    
    /**
     The action button has been pressed on the layout.
     
     :param: actionButton  The action button.
     */
    func cocoaBarLayoutActionButtonPressed(actionButton: UIButton?)
}