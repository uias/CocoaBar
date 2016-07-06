//
//  CocoaBarLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

/**
 The layout view that is displayed within the CocoaBar. 
 Available to subclass to create custom layouts.
 */
public class CocoaBarLayout: DropShadowView {
    
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
    
    public enum DisplayStyle {
        /**
         Standard rectangular display. Full width of screen on iPhone.
         */
        case Standard
        /**
         Rounded Rectangle display.
         */
        case RoundRectangle
    }
    
    // MARK: Defaults
    
    public struct Colors {
        /**
         Default key line color when using light background style (lightGray)
         */
        public static let KeylineColor: UIColor = UIColor.lightGrayColor()
        /**
         Default key line color when using dark background style (black with 0.3 alpha)
         */
        public static let KeylineColorDark: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    }
    
    internal struct Dimensions {
        
        struct RoundRectangle {
            static let CornerRadius: CGFloat = 10.0
            static let ExternalPadding: CGFloat = 6.0
        }
    }
    
    // MARK: Variables
    
    private var contentView: UIView?
    private var contentViewLeftMargin: NSLayoutConstraint?
    private var contentViewRightMargin: NSLayoutConstraint?
    private var contentViewBottomMargin: NSLayoutConstraint?

    private var customNibName: String?
    private var nibView: UIView?
    
    private var backgroundContainer: UIView?
    
    private var keylineView: UIView?
    private var customKeylineColor: UIColor?
    
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
    internal weak var delegate: CocoaBarLayoutDelegate?
    
    /**
     The dismiss button on the layout
     */
    @IBOutlet public weak var dismissButton: UIButton? {
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
    @IBOutlet public weak var actionButton: UIButton? {
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
    public var backgroundStyle: BackgroundStyle = .BlurLight {
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
                    return Colors.KeylineColorDark
                default:
                    return Colors.KeylineColor

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
     The display style to use for the layout. Defaults to Standard.
     */
    public var displayStyle: DisplayStyle = DisplayStyle.Standard {
        willSet (newDisplayStyle) {
            if newDisplayStyle != self.displayStyle {
                self.updateDisplayStyle(newDisplayStyle)
            }
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
        
        let contentView = UIView()
        self.addSubview(contentView)
        let constraints = contentView.autoPinToEdges()
        contentView.clipsToBounds = true
        self.contentView = contentView
        self.contentViewLeftMargin = constraints?.first
        self.contentViewRightMargin = constraints?[1]
        self.contentViewBottomMargin = constraints?[3]
        
        let backgroundContainer = UIView()
        contentView.addSubview(backgroundContainer)
        backgroundContainer.autoPinToEdges()
        self.backgroundContainer = backgroundContainer
        
        let keylineView = UIView()
        contentView.addSubview(keylineView)
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
            
            self.contentView?.addSubview(view)
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
                
            case .BlurLight, .BlurDark:
                self.backgroundColor = UIColor.clearColor()
                
                var style: UIBlurEffectStyle
                switch newStyle {
                case .BlurDark: style = UIBlurEffectStyle.Dark
                default: style = UIBlurEffectStyle.ExtraLight
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
    
    private func updateDisplayStyle(displayStyle: DisplayStyle) {
        
        switch displayStyle {
        case .RoundRectangle:
            self.contentView?.layer.cornerRadius = Dimensions.RoundRectangle.CornerRadius
            self.keylineView?.hidden = true
            self.contentViewLeftMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            self.contentViewRightMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            self.contentViewBottomMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            
        default:
            self.contentView?.layer.cornerRadius = 0.0
            self.keylineView?.hidden = false
            self.contentViewLeftMargin?.constant = 0.0
            self.contentViewRightMargin?.constant = 0.0
            self.contentViewBottomMargin?.constant = 0.0
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
    
    /**
     Prepare the layout prior to it being shown in the CocoaBar.
     */
    public func prepareLayoutForShowing() {
        
    }
    
    /**
     Prepare the layout prior to it being hidden in the CocoaBar.
     */
    public func prepareLayoutForHiding() {
        
    }
    
    // MARK: Internal
    
    /**
     Internally prepare the layout for showing.
     */
    internal func prepareForShow() {
        self.prepareLayoutForShowing()
    }
    
    /**
     Internally prepare the layout for hiding.
     */
    internal func prepareForHide() {
        self.prepareLayoutForHiding()
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

internal protocol CocoaBarLayoutDelegate: class {
    
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