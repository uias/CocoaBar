//
//  ViewController.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CocoaBarDelegate {

    // MARK: Properties
    
    @IBOutlet weak var gradientView: GradientView?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var separatorView: UIView?
    
    var styles: [BarStyle] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradientView?.colors = [UIColor.purple, UIColor(red: 29, green: 0, blue: 174)]
        
        self.styles.append(BarStyle(title: "Default - Light",
            description: "Default text-only layout with light blur background",
            backgroundStyle: .blurLight,
            displayStyle: .standard,
            barStyle: .default,
            duration: .long))
        self.styles.append(BarStyle(title: "Default - Dark",
            description: "Default text-only layout with dark blur background",
            backgroundStyle: .blurDark,
            displayStyle: .standard,
            barStyle: .default,
            duration: .long))
        self.styles.append(BarStyle(title: "Action - Light",
            description: "Action layout with light blur background",
            backgroundStyle: .blurLight,
            displayStyle: .standard,
            barStyle: .action,
            duration: .indeterminate))
        self.styles.append(BarStyle(title: "Action - Round Rect Dark",
            description: "Action layout with dark blur background and rounded rectangular display",
            backgroundStyle: .blurDark,
            displayStyle: .roundRectangle,
            barStyle: .action,
            duration: .indeterminate))
        self.styles.append(BarStyle(title: "Custom Layout",
            description: "Custom CocoaBarLayout",
            backgroundStyle: .blurLight,
            displayStyle: .standard,
            layout: CustomCocoaBarLayout(),
            duration: .long))
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 96.0
        self.tableView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaBar.keyCocoaBar?.delegate = self
    }

    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.styles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let barStyleCell = tableView.dequeueReusableCell(withIdentifier: "BarStyleCell") as! BarStyleCell
        let style = self.styles[(indexPath as NSIndexPath).row]
        
        barStyleCell.titleLabel?.text = style.title
        barStyleCell.descriptionLabel?.text = style.styleDescription
        
        let selectedBackgroundView = UIView()
        
        // alternate row colours
        if (indexPath as NSIndexPath).row % 2 != 0 {
            barStyleCell.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            selectedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        } else {
            barStyleCell.backgroundColor = UIColor.clear
            selectedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        
        
        barStyleCell.selectedBackgroundView = selectedBackgroundView
        
        return barStyleCell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let style = self.styles[(indexPath as NSIndexPath).row]
        
        if let keyCocoaBar = CocoaBar.keyCocoaBar {
            if keyCocoaBar.isShowing {
                keyCocoaBar.delegate = nil // temporarily ignore cocoa bar delegate
                keyCocoaBar.hideAnimated(true, completion: { (animated, completed, visible) in
                    self.showBarWithStyle(style)
                    keyCocoaBar.delegate = self
                })
            } else {
                self.showBarWithStyle(style)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 { // show separator
            if self.separatorView?.alpha != 1.0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.separatorView?.alpha = 1.0
                })
            }
        } else { // hide separator
            if self.separatorView?.alpha != 0.0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.separatorView?.alpha = 0.0
                })
            }
        }
    }
    
    // MARK: CocoaBarDelegate
    
    func cocoaBar(_ cocoaBar: CocoaBar, willShowAnimated animated: Bool) {
        
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, didShowAnimated animated: Bool) {
        // did show bar
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, willHideAnimated animated: Bool) {
        if let indexPath = self.tableView?.indexPathForSelectedRow {
            self.tableView?.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, didHideAnimated animated: Bool) {
        
    }
    
    func cocoaBar(_ cocoaBar: CocoaBar, actionButtonPressed actionButton: UIButton?) {
        // Do an action
        if let actionLayout = cocoaBar.layout as? CocoaBarActionLayout { // action layout - show spinner
            actionLayout.startLoading()
            
            delay(4.0, closure: { 
                cocoaBar.hideAnimated(true, completion: nil)
            })
        }
    }
    
    // MARK: Private
    
    fileprivate func showBarWithStyle(_ style: BarStyle) {
        if style.layout != nil {
            CocoaBar.showAnimated(true, duration: style.duration, layout: style.layout, populate: { (layout) in
                self.populateLayout(style, layout: layout)
                }, completion: nil)
        }
        
        CocoaBar.showAnimated(true, duration: style.duration, style: style.barStyle, populate: { (layout) in
            self.populateLayout(style, layout: layout)
            }, completion: nil)
    }
    
    fileprivate func populateLayout(_ style: BarStyle, layout: CocoaBarLayout) {
        layout.backgroundStyle = style.backgroundStyle
        layout.displayStyle = style.displayStyle
        
        if let defaultLayout = layout as? CocoaBarDefaultLayout {
            defaultLayout.titleLabel?.text = "This is the default layout"
        }
        if let actionLayout = layout as? CocoaBarActionLayout {
            actionLayout.titleLabel?.text = "This is the action layout"
        }
    }
    
    fileprivate func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

