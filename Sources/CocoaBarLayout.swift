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
open class CocoaBarLayout: DropShadowView {
    
    /**
     BackgroundStyle dictates the appearance of the background view
     in the layout.
     */
    public enum BackgroundStyle {
        /**
         SolidColor relies on setting the backgroundColor property of the layout.
         */
        case solidColor
        /**
         BlurExtraLight displays a blur view with UIBlurEffectStyle.ExtraLight
         */
        case blurLight
        /**
         BlurDark displays a blur view with UIBlurEffectStyle.Dark
         */
        case blurDark
        /**
         Custom provides a UIView to the backgroundView property for enhanced
         customisation.
         */
        case custom
    }
    
    public enum DisplayStyle {
        /**
         Standard rectangular display. Full width of screen on iPhone.
         */
        case standard
        /**
         Rounded Rectangle display.
         */
        case roundRectangle
    }
    
    // MARK: Defaults
    
    public struct Colors {
        /**
         Default key line color when using light background style (lightGray)
         */
        public static let KeylineColor: UIColor = UIColor.lightGray
        /**
         Default key line color when using dark background style (black with 0.3 alpha)
         */
        public static let KeylineColorDark: UIColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    internal struct Dimensions {
        
        struct RoundRectangle {
            static let CornerRadius: CGFloat = 12.0
            static let ExternalPadding: CGFloat = 6.0
        }
    }
    
    // MARK: Properties
    
    private var contentView: UIView?
    private var contentViewLeftMargin: NSLayoutConstraint?
    private var contentViewRightMargin: NSLayoutConstraint?
    private var contentViewBottomMargin: NSLayoutConstraint?
    
    private var backgroundContainer: UIView?
    
    private var keylineView: UIView?
    private var customKeylineColor: UIColor?
    
    private var customNibName: String?
    fileprivate var nibName: String {
        get {
            guard let nibName = customNibName else {
                return String(describing: self.classForCoder)
            }
            return nibName
        }
        set {
            customNibName = newValue
        }
    }
    fileprivate var nibView: UIView?
    
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
                                        for: UIControlEvents.touchUpInside)
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
                                        for: UIControlEvents.touchUpInside)
            }
        }
    }
    
    /**
     The background style to use for the layout. Defaults to BlurExtraLight.
     */
    open var backgroundStyle: BackgroundStyle = .blurLight {
        didSet {
            self.updateBackgroundStyle(self.backgroundStyle)
        }
    }
    
    /**
     The background view in the layout. This is only available when using .Custom
     for the backgroundStyle.
     */
    public fileprivate(set) var backgroundView: UIView?
    
    /**
     The height required for the layout. Uses CocoaBarLayoutDefaultHeight if custom
     height not specified.
     */
    public fileprivate(set) var height: Float?
    
    /**
     The color of the keyline at the top of the layout.
     */
    open var keylineColor: UIColor {
        get {
            guard let keylineColor = customKeylineColor else {
                switch self.backgroundStyle {
                case .blurDark:
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
    open var displayStyle: DisplayStyle = DisplayStyle.standard {
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
        
        super.init(frame: CGRect.zero)
        
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

    // MARK: Appearance
    
    private func setUpBackgroundView() {
        
        let contentView = UIView()
        self.addSubview(contentView)
        let constraints = contentView.cb_autoPinToEdges()
        contentView.clipsToBounds = true
        self.contentView = contentView
        self.contentViewLeftMargin = constraints?.first
        self.contentViewRightMargin = constraints?[1]
        self.contentViewBottomMargin = constraints?[3]
        
        let backgroundContainer = UIView()
        contentView.addSubview(backgroundContainer)
        backgroundContainer.cb_autoPinToEdges()
        self.backgroundContainer = backgroundContainer
        
        let keylineView = UIView()
        contentView.addSubview(keylineView)
        keylineView.cb_autoPinToSidesAndTop()
        keylineView.cb_autoSetHeight(1.0)
        self.keylineView = keylineView
    }
    
    private func setUpNibView() {
        
        // check if nib exists
        let bundle = Bundle(for: self.classForCoder)
        if bundle.path(forResource: self.nibName, ofType: "nib") != nil {
            
            let nib = UINib(nibName: self.nibName, bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            self.nibView = view
            
            self.contentView?.addSubview(view)
            view.cb_autoPinToEdges()
            
            // view is transparent
            view.backgroundColor = UIColor.clear
        }
    }
    
    private func setUpAppearance() {
        
        self.keylineView?.backgroundColor = self.keylineColor
        
        self.updateBackgroundStyle(self.backgroundStyle)
    }
    
    private func updateBackgroundStyle(_ newStyle: BackgroundStyle) {
        if let backgroundContainer = self.backgroundContainer {
            
            // clear subviews
            for view in backgroundContainer.subviews{
                view.removeFromSuperview()
            }
            self.backgroundView = nil
            
            switch newStyle {
                
            case .blurLight, .blurDark:
                self.backgroundColor = UIColor.clear
                
                var style: UIBlurEffectStyle
                switch newStyle {
                case .blurDark: style = UIBlurEffectStyle.dark
                default: style = UIBlurEffectStyle.extraLight
                }
                
                // add blur view
                let blurEffect = UIBlurEffect(style: style)
                let visualEffectView = UIVisualEffectView(effect: blurEffect)
                
                backgroundContainer.addSubview(visualEffectView)
                visualEffectView.cb_autoPinToEdges()
                
            case .custom:
                self.backgroundColor = UIColor.clear
                
                // create custom background view
                let backgroundView = UIView()
                backgroundContainer.addSubview(backgroundView)
                backgroundView.cb_autoPinToEdges()
                self.backgroundView = backgroundView
                
            default:()
            }
            
            self.keylineView?.backgroundColor = self.keylineColor
            self.updateLayoutForBackgroundStyle(newStyle, backgroundView: self.backgroundView)
        }
    }
    
    private func updateDisplayStyle(_ displayStyle: DisplayStyle) {
        
        switch displayStyle {
        case .roundRectangle:
            self.contentView?.layer.cornerRadius = Dimensions.RoundRectangle.CornerRadius
            self.keylineView?.isHidden = true
            self.contentViewLeftMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            self.contentViewRightMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            self.contentViewBottomMargin?.constant = Dimensions.RoundRectangle.ExternalPadding
            
        default:
            self.contentView?.layer.cornerRadius = 0.0
            self.keylineView?.isHidden = false
            self.contentViewLeftMargin?.constant = 0.0
            self.contentViewRightMargin?.constant = 0.0
            self.contentViewBottomMargin?.constant = 0.0
        }
    }
    
    // MARK: Layout
    
    /**
     The height required for the bar layout. Override this to manually specify a
     height for the cocoa bar layout.
     */
    open func requiredHeight() -> Float {
        return 0
    }
    
    /**
     Update the layout when the background style changes.
     
     :param: newStyle           The new background style.
     :param: backgroundView     The custom background view (only available when
     using .Custom backgroundStyle).
     */
    open func updateLayoutForBackgroundStyle(_ newStyle: BackgroundStyle, backgroundView: UIView?) {
        
    }
    
    /**
     Prepare the layout prior to it being shown in the CocoaBar.
     */
    open func prepareLayoutForShowing() {
        
    }
    
    /**
     Prepare the layout prior to it being hidden in the CocoaBar.
     */
    open func prepareLayoutForHiding() {
        
    }
    
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
    
    @objc func closeButtonPressed(_ sender: UIButton?) {
        if let delegate = self.delegate {
            delegate.cocoaBarLayoutDismissButtonPressed(sender)
        }
    }
    
    @objc func actionButtonPressed(_ sender: UIButton?) {
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
    func cocoaBarLayoutDismissButtonPressed(_ dismissButton: UIButton?)
    
    /**
     The action button has been pressed on the layout.
     
     :param: actionButton  The action button.
     */
    func cocoaBarLayoutActionButtonPressed(_ actionButton: UIButton?)
}
