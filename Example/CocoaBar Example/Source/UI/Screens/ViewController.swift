//
//  ViewController.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var gradientView: GradientView?
    @IBOutlet weak var tableView: UITableView?
    
    var styles: [BarStyle] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gradientView?.colors = [UIColor.purpleColor(), UIColor(red: 29, green: 0, blue: 174)]
        
        self.styles.append(BarStyle(title: "Compressed Error",
            description: "Compressed Error Layout with ultra light background",
            backgroundStyle: .BlurDark,
            barStyle: .ErrorExpanded,
            duration: .Long))
        self.styles.append(BarStyle(title: "Expanded Error Light",
            description: "Expanded Error layout with light background",
            backgroundStyle: .BlurLight,
            barStyle: .ErrorExpanded,
            duration: .Long))
        self.styles.append(BarStyle(title: "Expanded Error Dark",
            description: "Expanded Error Layout with dark background",
            backgroundStyle: .BlurDark,
            barStyle: .ErrorExpanded,
            duration: .Long))
        self.styles.append(BarStyle(title: "Custom Layout",
            description: "Custom CocoaBarLayout",
            backgroundStyle: .BlurDark,
            barStyle: .ErrorExpanded,
            duration: .Long))
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 96.0
        self.tableView?.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaBar.showAnimated(false, duration: .Indeterminate, layout: nil, populate: { (layout) in
            
            }, completion: nil)
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
        
        // alternate row colours
        if indexPath.row % 2 != 0 {
            barStyleCell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15)
        }
        
        return barStyleCell
    }
    
    // MARK: UITableViewDelegate
    
    
    @IBAction func showButtonPressed(sender: UIButton) {
        
        CocoaBar.showAnimated(true, duration: .Short, style: .ErrorCondensed, populate: { (layout) in
            
            }, completion: nil)
    }
}

