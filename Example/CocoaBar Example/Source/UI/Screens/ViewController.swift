//
//  ViewController.swift
//  CocoaBar Example
//
//  Created by Merrick Sapsford on 23/05/2016.
//  Copyright © 2016 Merrick Sapsford. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGrayColor()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        CocoaBar.show(false,
                      duration: CocoaBar.DisplayDuration.Short,
                      populate:
            { (layout) in
                
            },
                      completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func showButtonPressed(sender: UIButton) {
        CocoaBar.show(true,
                      duration: CocoaBar.DisplayDuration.Short,
                      populate:
            { (layout) in
                
            },
                      completion: nil)
    }
}

