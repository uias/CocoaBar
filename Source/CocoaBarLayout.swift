//
//  CocoaBarLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout

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

public class CocoaBarLayout: UIView {
    
    // MARK: Defaults
    
    let CocoaBarLayoutDefaultHeight: Float = 60.0
    let CocoaBarLayoutDefaultKeylineColor: UIColor = UIColor.lightGrayColor()
    let CocoaBarLayoutDefaultKeylineColorDark: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    
    // MARK: Variables
    
    private var _nibName: String?
    private var _nibView: UIView?
    
    private var _height: Float?
    
    private var backgroundContainer: UIView?
    private var _backgroundView: UIView?
    
    private var keylineView: UIView?
    private var _keylineColor: UIColor?
    
    private var nibName: String {
        get {
            guard let nibName = _nibName else {
                return String(self.classForCoder)
            }
            return nibName
        }
        set {
            _nibName = newValue
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
        willSet {
            if newValue != self.backgroundStyle {
                self.updateBackgroundStyle(newValue)
            }
        }
    }
    
    /**
     The background view in the layout. This is only available when using .Custom
     for the backgroundStyle.
     */
    public var backgroundView: UIView? {
        get {
            return _backgroundView
        }
    }
    
    /**
     The height required for the layout. Uses CocoaBarLayoutDefaultHeight if custom
     height not specified.
     */
    public private(set) var height: Float {
        get {
            guard let height = _height else {
                return CocoaBarLayoutDefaultHeight
            }
            return height
        }
        set {
            _height = height
        }
    }
    
    /**
     The color of the keyline at the top of the layout.
     */
    public var keylineColor: UIColor {
        get {
            guard let keylineColor = _keylineColor else {
                switch self.backgroundStyle {
                case .BlurDark:
                    return CocoaBarLayoutDefaultKeylineColorDark
                default:
                    return CocoaBarLayoutDefaultKeylineColor

                }
            }
            return keylineColor
        }
        set {
            _keylineColor = newValue
            self.keylineView?.backgroundColor = newValue
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
        _nibName = nibName
        
        super.init(frame: CGRectZero)
        
        self.setUpBackgroundView()
        self.setUpNibView()
        self.setUpAppearance()
        
        if let height = height {
            _height = height
        } else if self.requiredHeight() > 0 {
            _height = self.requiredHeight()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setUpBackgroundView()
        self.setUpNibView()
    }

    // MARK: Private
    
    private func setUpBackgroundView() {
        
        let backgroundContainer = UIView()
        self.addSubview(backgroundContainer)
        backgroundContainer.autoPinEdgesToSuperviewEdges()
        self.backgroundContainer = backgroundContainer
        
        let keylineView = UIView()
        self.addSubview(keylineView)
        keylineView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: ALEdge.Bottom)
        keylineView.autoSetDimension(ALDimension.Height, toSize: 1.0)
        self.keylineView = keylineView
    }
    
    private func setUpNibView() {
        
        // check if nib exists
        let bundle = NSBundle(forClass: self.classForCoder)
        if bundle.pathForResource(self.nibName, ofType: "nib") != nil {
            
            let nib = UINib(nibName: self.nibName, bundle: bundle)
            let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
            _nibView = view
            
            self.addSubview(view)
            view.autoPinEdgesToSuperviewEdges()
            
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
            _backgroundView = nil
            
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
                visualEffectView.autoPinEdgesToSuperviewEdges()
                
            case .Custom:
                self.backgroundColor = UIColor.clearColor()
                
                // create custom background view
                let backgroundView = UIView()
                backgroundContainer.addSubview(backgroundView)
                backgroundView.autoPinEdgesToSuperviewEdges()
                _backgroundView = backgroundView
                
            default:()
            }
            
            self.updateLayoutForBackgroundStyle(newStyle, backgroundView: _backgroundView)
        }
    }
    
    // MARK: Internal
    
    /**
     The height required for the bar layout. Override this to manually specify a 
     height for the cocoa bar layout.
    */
    internal func requiredHeight() -> Float {
        if let nibView = _nibView {
            let requiredSize = nibView.requiredSizeWithWidth(self.bounds.size.width, requiredHeight: nil)
            return Float(requiredSize.height)
        }
        return 0
    }
    
    /**
     Update the layout when the background style changes.
     
     :param: newStyle           The new background style.
     :param: backgroundView     The custom background view (only available when 
                                using .Custom backgroundStyle).
     */
    internal func updateLayoutForBackgroundStyle(newStyle: BackgroundStyle, backgroundView: UIView?) {
        
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