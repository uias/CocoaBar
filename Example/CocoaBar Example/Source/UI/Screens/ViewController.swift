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

        self.gradientView?.colors = [UIColor.purpleColor(), UIColor(red: 29, green: 0, blue: 174)]
        
        self.styles.append(BarStyle(title: "Default - Light",
            description: "Default Layout with extra light blur background",
            backgroundStyle: .BlurExtraLight,
            barStyle: .Default,
            duration: .Long))
        self.styles.append(BarStyle(title: "Default - Dark",
            description: "Default layout with dark blur background",
            backgroundStyle: .BlurDark,
            barStyle: .Default,
            duration: .Long))
        self.styles.append(BarStyle(title: "Custom Layout",
            description: "Custom CocoaBarLayout",
            backgroundStyle: .BlurExtraLight,
            layout: CustomCocoaBarLayout(),
            duration: .Long))
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 96.0
        self.tableView?.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaBar.keyCocoaBar?.delegate = self
    }

    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.styles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let barStyleCell = tableView.dequeueReusableCellWithIdentifier("BarStyleCell") as! BarStyleCell
        let style = self.styles[indexPath.row]
        
        barStyleCell.titleLabel?.text = style.title
        barStyleCell.descriptionLabel?.text = style.styleDescription
        
        let selectedBackgroundView = UIView()
        
        // alternate row colours
        if indexPath.row % 2 != 0 {
            barStyleCell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15)
            selectedBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        } else {
            selectedBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        }
        
        
        barStyleCell.selectedBackgroundView = selectedBackgroundView
        
        return barStyleCell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let style = self.styles[indexPath.row]
        
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 { // show separator
            if self.separatorView?.alpha != 1.0 {
                UIView.animateWithDuration(0.2, animations: {
                    self.separatorView?.alpha = 1.0
                })
            }
        } else { // hide separator
            if self.separatorView?.alpha != 0.0 {
                UIView.animateWithDuration(0.2, animations: {
                    self.separatorView?.alpha = 0.0
                })
            }
        }
    }
    
    // MARK: CocoaBarDelegate
    
    func cocoaBar(cocoaBar: CocoaBar, didShowAnimated animated: Bool) {
        // did show bar
    }
    
    func cocoaBar(cocoaBar: CocoaBar, didHideAnimated animated: Bool) {
        if let indexPath = self.tableView?.indexPathForSelectedRow {
            self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func cocoaBar(cocoaBar: CocoaBar, actionButtonPressed actionButton: UIButton?) {
        // Do an action
    }
    
    // MARK: Private
    
    private func showBarWithStyle(style: BarStyle) {
        if style.layout != nil {
            CocoaBar.showAnimated(true, duration: style.duration, layout: style.layout, populate: { (layout) in
                self.populateLayout(style, layout: layout)
                }, completion: nil)
        }
        
        CocoaBar.showAnimated(true, duration: style.duration, style: style.barStyle, populate: { (layout) in
            self.populateLayout(style, layout: layout)
            }, completion: nil)
    }
    
    private func populateLayout(style: BarStyle, layout: CocoaBarLayout) {
        layout.backgroundStyle = style.backgroundStyle
        
        if let defaultLayout = layout as? CocoaBarDefaultLayout {
            defaultLayout.titleLabel?.text = "This is the default layout"
        }
        
//        if let expandedErrorLayout = layout as? CocoaBarErrorExpandedLayout {
//            expandedErrorLayout.titleLabel?.text = "Expanded Error Layout"
//            expandedErrorLayout.subtitleLabel?.text = "This one lets you have a bit of detail"
//        } else if let condensedErrorLayout = layout as? CocoaBarErrorCondensedLayout {
//            condensedErrorLayout.titleLabel?.text = "A nice simple short error layout"
//        }
    }
}

