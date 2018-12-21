//
//  HomeSplitViewController.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/10/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Cocoa

class HomeSplitViewController: NSSplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.splitViewItems[0].minimumThickness = 280.00
        self.splitViewItems[1].minimumThickness = 500.00
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

