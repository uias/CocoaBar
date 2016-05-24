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
    
    // MARK: Variables
    private var _nibName: String?
    
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
    
    // MARK: Init
    
    convenience init() {
        self.init(nibName: nil)
    }
    
    init(nibName: String?) {
        _nibName = nibName
        super.init(frame: CGRectZero)
        
        self.setUpNibView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setUpNibView()
    }

    // MARK: Private
    
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