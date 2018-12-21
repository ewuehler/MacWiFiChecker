//
//  ViewController.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/9/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Cocoa

class WiFiTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTouchBarDelegate {

    let manager: WiFiDataManager = WiFiDataManager()
    
    @IBOutlet weak var wifiTableView: NSTableView!
    
    var sortByNameAscending: Bool = true
    var sortByDateAscending: Bool = true
    var sortBySecurityAscending: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.sort([NSSortDescriptor(key:SSIDString, ascending:sortByNameAscending)])
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {

        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .hotspotBar
        touchBar.defaultItemIdentifiers = [.totalHotspots, .openHotspots, .wepHotspots, .wpaHotspots]
        touchBar.customizationAllowedItemIdentifiers = [.totalHotspots, .openHotspots, .wepHotspots, .wpaHotspots]

        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.totalHotspots:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "Known: \(manager.networks.count)")
            return customViewItem
        case NSTouchBarItem.Identifier.openHotspots:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "Open: \(manager.openCount())")
            return customViewItem
        case NSTouchBarItem.Identifier.wepHotspots:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "WEP: \(manager.wepCount())")
            return customViewItem
        case NSTouchBarItem.Identifier.wpaHotspots:
            let customViewItem = NSCustomTouchBarItem(identifier: identifier)
            customViewItem.view = NSTextField(labelWithString: "WPA: \(manager.wpaCount())")
            return customViewItem
        default:
            return nil
        }
    }

 func reloadWithFile(_ fileName: String) {
        manager.reloadWithFile(fileName)
        wifiTableView.reloadData()
    }

    func reloadSystemConfiguration() {
        manager.reloadSystemConfiguration()
        wifiTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return manager.networks.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let data:WiFiData = manager.networks[wifiTableView.selectedRow]
        let detailViewController = self.parent?.children[1] as! WiFiDetailViewController
        detailViewController.populate(data)
        
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let data: WiFiData = manager.networks[row]
        return data
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let data: WiFiData = manager.networks[row]
        
        let cell:WiFiTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! WiFiTableCellView
        
        cell.ssidTextField.stringValue = data.SSIDString
        cell.lastTextField.stringValue = data.lastConnectedString()
        let image:NSImage = data.securityImage()!
//        if (data.SecurityTypeInt > 10) { // Booo! Magic numbers! FIXME
//            
//            // Color code and background
//            let colorFilter:CIFilter = CIFilter(name: "CIFalseColor")!
//            colorFilter.setDefaults()
//            colorFilter.setValue(image, forKey: "inputImage")
//            colorFilter.setValue(CIColor(red: 0,green: 1,blue: 0), forKey: "inputColor0")
//            colorFilter.setValue(CIColor(red: 0,green: 1,blue: 0) , forKey: "inputColor1")
//            let rep: NSCIImageRep = NSCIImageRep(ciImage: colorFilter.outputImage!)
//            let greenImage: NSImage = NSImage(size: rep.size)
//            greenImage.addRepresentation(rep)
//            cell.statusImageView.image = greenImage
//        } else {
            cell.statusImageView.image = image
//        }
        cell.wifiID = data.WiFiID
        
        return cell
    }
    
    func sortByName() {
        sortByNameAscending = !sortByNameAscending
        manager.sort([NSSortDescriptor(key:SSIDString, ascending:sortByNameAscending)])
        self.wifiTableView.reloadData()
    }
    
    func sortByDate() {
        sortByDateAscending = !sortByDateAscending
        manager.sort([NSSortDescriptor(key:SSIDString, ascending:sortByNameAscending),NSSortDescriptor(key:LastConnected, ascending:sortByDateAscending)])
        self.wifiTableView.reloadData()
        
    }
    
    func sortBySecurity() {
        sortBySecurityAscending = !sortBySecurityAscending
        manager.sort([NSSortDescriptor(key:SSIDString, ascending:sortByNameAscending),NSSortDescriptor(key:SecurityType, ascending:sortBySecurityAscending)])
        
        self.wifiTableView.reloadData()
    }
    
    func sortByPreferredOrder() {
        manager.sort([NSSortDescriptor(key:PreferredOrder, ascending:true)])
        
        self.wifiTableView.reloadData()
    }
}

