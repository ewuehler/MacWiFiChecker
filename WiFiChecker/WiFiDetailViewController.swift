//
//  WiFiDetailViewController.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/13/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Cocoa

class WiFiDetailViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    fileprivate var data: WiFiData = WiFiData("Empty")
    fileprivate var propertiesData: Array<WiFiProperty> = []
    fileprivate var channelHistoryData: Array<ChannelData> = []
    fileprivate var bssidListData: Array<BSSIDData> = []
    fileprivate var collocatedGroupData: Array<CollocatedGroupData> = []
    fileprivate var cachedManufacturerData: Dictionary<String, String> = [:]
    
    @IBOutlet weak var ssidTextField: NSTextField!
    @IBOutlet weak var securityImageView: NSImageView!
    @IBOutlet weak var securityTextField: NSTextField!
    @IBOutlet weak var lastConnectedTextField: NSTextField!
    
    @IBOutlet weak var propertiesTableView: NSTableView!
    @IBOutlet weak var channelHistoryTableView: NSTableView!
    @IBOutlet weak var bssidListTableView: NSTableView!
    @IBOutlet weak var collocatedGroupTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    func populate(_ with: WiFiData) {
        self.data = with
        
        // Reset all the fields
        ssidTextField.stringValue = ""
        securityImageView.image = nil
        securityTextField.stringValue = ""
        lastConnectedTextField.stringValue = ""
        propertiesData.removeAll()
        channelHistoryData.removeAll()
        collocatedGroupData.removeAll()
        bssidListData.removeAll()
        cachedManufacturerData.removeAll()
        
        // Populate with new WiFiData
        ssidTextField.stringValue = data.SSIDString
        securityImageView.image = data.securityImage()
        securityTextField.stringValue = data.SecurityType
        lastConnectedTextField.stringValue = data.lastConnectedString()
        
        propertiesData.append(WiFiProperty(key: "Auto Login",value: data.AutoLogin))
        propertiesData.append(WiFiProperty(key: "Captive Portal",value: data.Captive))
        propertiesData.append(WiFiProperty(key: "Closed",value: data.Closed))
        propertiesData.append(WiFiProperty(key: "Disabled",value: data.Disabled))
        propertiesData.append(WiFiProperty(key: "Passpoint",value: data.Passpoint))
        propertiesData.append(WiFiProperty(key: "Personal Hotspot",value: data.PersonalHotspot))
        propertiesData.append(WiFiProperty(key: "Possibly Hidden Network",value: data.PossiblyHiddenNetwork))
        propertiesData.append(WiFiProperty(key: "SP Roaming",value: data.SPRoaming))
        propertiesData.append(WiFiProperty(key: "System Mode",value: data.SystemMode))
        propertiesData.append(WiFiProperty(key: "Temporarily Disabled",value: data.TemporarilyDisabled))
        propertiesTableView.reloadData()
        
        channelHistoryData = data.ChannelHistory ?? []
        channelHistoryTableView.reloadData()

        collocatedGroupData = data.CollocatedGroupDetails 
        collocatedGroupTableView.reloadData()
        
        bssidListData = data.BSSIDList ?? []
        bssidListTableView.reloadData()
        
        
        // Now loop through the bssidListData and add the manufacturer
        for bssiddata in bssidListData {
            // check cache
            let mfg = cachedManufacturerData[bssiddata.oui()]
            if (mfg == nil) {
                bssiddata.SSID = data.SSIDString
                addManufacturerInfo(urlString: "https://api.macvendors.com/\(bssiddata.mac())", bssidData: bssiddata)
                sleep(1)  // This is here because the API now rate limits to 1 request per second, 1000 per day
            } else {
                bssiddata.Manufacturer = mfg!
            }
        }
        
        
    }
    
    func addManufacturerInfo(urlString:String, bssidData: BSSIDData) {

        let url = URL(string:urlString.trimmingCharacters(in: .whitespaces))
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // TODO: pop a dialog with whatever magic error occurs - or otherwise notify user of boo-boo
                bssidData.Manufacturer = "[Error retrieving name]"
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let result = responseString ?? "[Unknown]"
            if (result.hasPrefix("{\"errors")) {
                bssidData.Manufacturer = "[Error]"
            } else {
                bssidData.Manufacturer = result
            }
            print("Found \(bssidData.Manufacturer) for \(bssidData.SSID)")
            DispatchQueue.main.async {
                self.cachedManufacturerData[bssidData.mac()] = bssidData.Manufacturer
                self.bssidListTableView.reloadData()
            }
        }
        task.resume()
        
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if (tableView == propertiesTableView) {
            return propertiesData.count
        } else if (tableView == channelHistoryTableView) {
            return channelHistoryData.count
        } else if (tableView == collocatedGroupTableView) {
            return collocatedGroupData.count
        } else if (tableView == bssidListTableView) {
            return bssidListData.count
        }
        
        return 0
    }
    
    
  
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if (tableView == propertiesTableView) {
        
            let cell:NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            let prop: WiFiProperty = propertiesData[row]
            cell.textField?.stringValue = prop.key
            cell.textField?.textColor = prop.value ? NSColor.black : NSColor.gray
            cell.imageView?.image = prop.value ? NSImage(named: NSImage.statusAvailableName) : NSImage(named: NSImage.statusNoneName)
            
            return cell
        } else if (tableView == channelHistoryTableView) {
            
            let cell:NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if (convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "channel") {
                cell.textField?.intValue = Int32(channelHistoryData[row].Channel)
            } else {
                cell.textField?.stringValue = channelHistoryData[row].timestampString()
            }
            return cell
        } else if (tableView == collocatedGroupTableView) {
            
            let cell: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if (convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "ssid") {
                cell.textField?.stringValue = collocatedGroupData[row].ssid
                cell.imageView?.image = collocatedGroupData[row].secure ? NSImage(named: NSImage.lockLockedTemplateName) : NSImage(named: NSImage.lockUnlockedTemplateName)
            } else {
                cell.textField?.stringValue = collocatedGroupData[row].lastConnectedString()
            }
            return cell
        } else if (tableView == bssidListTableView) {
            let cell: NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
            if (convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) == "mac") {
                cell.textField?.stringValue = bssidListData[row].mac()
                cell.textField?.font = NSFont(name: "Courier", size: 12.0)
            } else {
                cell.textField?.stringValue = bssidListData[row].Manufacturer
            }
            return cell
        }
        
        
        return nil
    }

    
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {

        if (tableView == channelHistoryTableView) {
            
            channelHistoryData = data.sortChannelData(tableView.sortDescriptors)
            tableView.reloadData()
        }
        
        
    }

   
}

class WiFiProperty {
    var key: String
    var value: Bool
    
    init(key: String, value: Bool) {
        self.key = key
        self.value = value
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}
