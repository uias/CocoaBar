//
//  CocoaBarLayout.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 24/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit
import PureLayout

class CocoaBarLayout: UIView {
    
    // MARK: Enums
    
    enum BackgroundStyle {
        case SolidColor
        case BlurExtraLight
        case BlurLight
        case BlurDark
        case Custom
    }
    
    // MARK: Variables
    private var _nibName: String?
    
    private var backgroundContainer: UIView?
    private var _backgroundView: UIView?
    
    // MARK: Properties
    
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
    
    var delegate: CocoaBarLayoutDelegate?
    
    @IBOutlet weak var dismissButton: UIButton? {
        willSet {
            if let dismissButton = newValue {
                dismissButton.addTarget(self,
                                        action: #selector(closeButtonPressed),
                                        forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    @IBOutlet weak var actionButton: UIButton? {
        willSet {
            if let actionButton = newValue {
                actionButton.addTarget(self,
                                        action: #selector(actionButtonPressed),
                                        forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
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
    
    // MARK: Init
    
    convenience init() {
        self.init(nibName: nil)
    }
    
    init(nibName: String?) {
        _nibName = nibName
        super.init(frame: CGRectZero)
        
        self.setUpBackgroundView()
        self.setUpNibView()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        
        self.updateBackgroundStyle(self.backgroundStyle)
    }
    
    private func setUpNibView() {
        
        // check if nib exists
        let bundle = NSBundle(forClass: self.classForCoder)
        if bundle.pathForResource(self.nibName, ofType: "nib") != nil {
            
            let nib = UINib(nibName: self.nibName, bundle: bundle)
            let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
            
            self.addSubview(view)
            view.autoPinEdgesToSuperviewEdges()
        }
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
                backgroundContainer.backgroundColor = UIColor.clearColor()
                
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
                
                // create custom background view
                let backgroundView = UIView()
                backgroundContainer.addSubview(backgroundView)
                backgroundView.autoPinEdgesToSuperviewEdges()
                _backgroundView = backgroundView
                
            default:()
            }
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

protocol CocoaBarLayoutDelegate {
    
    func cocoaBarLayoutDismissButtonPressed(dismissButton: UIButton?)
    
    func cocoaBarLayoutActionButtonPressed(actionButton: UIButton?)
}