//
//  WiFiCollectionView.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/10/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Cocoa

class WiFiTableCellView: NSTableCellView {
    
    @IBOutlet weak var ssidTextField: NSTextField!
    @IBOutlet weak var statusImageView: NSImageView!
    @IBOutlet weak var lastTextField: NSTextField!
    
    var wifiID: String = ""
}

