//
//  HomeWindowController.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/13/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Cocoa

class HomeWindowController: NSWindowController {
    
    @IBOutlet weak var sortByName: NSToolbarItem!
    @IBOutlet weak var sortByDate: NSToolbarItem!
    @IBOutlet weak var sortBySecurity: NSToolbarItem!
    @IBOutlet weak var preferredOrder: NSToolbarItem!
    @IBOutlet weak var printIt: NSToolbarItem!

    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        return tableViewController.makeTouchBar()
    }

    var splitViewController: HomeSplitViewController {
        get {
            return self.window!.contentViewController! as! HomeSplitViewController
        }
    }

    var tableViewController: WiFiTableViewController {
        get {
            return self.splitViewController.splitViewItems[0].viewController as! WiFiTableViewController
        }
    }
    
    var detailViewController: WiFiDetailViewController {
        get {
            return self.splitViewController.splitViewItems[1].viewController as! WiFiDetailViewController
        }
    }
    
    @IBAction func printSelected(_ sender: Any) {

        //TODO: find smart people to fix this...
        
//        let printInfo: NSPrintInfo = NSPrintInfo.shared()
//        
//        let paperSize: NSSize = printInfo.paperSize
//        
//        let printView: NSView = self.detailViewController.view
//        
//        printView.setFrameSize(paperSize)
//        printView.needsDisplay = false
//        printView.needsDisplay = true
//        
//        let printOp: NSPrintOperation = NSPrintOperation(view: printView, printInfo: printInfo)
//        printOp.showsPrintPanel = true
//        printOp.run()
        
    }
    
    
    @IBAction func sortByNameSelected(_ sender: Any) {
        tableViewController.sortByName()
        if (sortByName.image?.name() == "AZ") {
            sortByName.image = NSImage(named: "ZA")
        } else {
            sortByName.image = NSImage(named: "AZ")
        }

    }
    
    @IBAction func sortByDateSelected(_ sender: Any) {
        tableViewController.sortByDate()
        if (sortByDate.image?.name() == "SortTimeAscending") {
            sortByDate.image = NSImage(named: "SortTimeDescending")
        } else {
            sortByDate.image = NSImage(named: "SortTimeAscending")
        }
    }

    @IBAction func sortBySecuritySelected(_ sender: Any) {
        tableViewController.sortBySecurity()
        if (sortBySecurity.image?.name() == "RYG") {
            sortBySecurity.image = NSImage(named: "GYR")
        } else {
            sortBySecurity.image = NSImage(named: "RYG")
        }
    }
    
    
    @IBAction func preferredOrderSelected(_ sender: Any) {
        
        tableViewController.sortByPreferredOrder()
    }
    
    @IBAction func loadAlternativeFile(_ sender:Any) {
        
        // Load File Dialog and select a new Plist
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .plist file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["plist"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                let path = result!.path
                tableViewController.reloadWithFile(path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    @IBAction func loadSystemConfiguration(_ sender: Any) {
        tableViewController.reloadSystemConfiguration()
    }
    
    
}


