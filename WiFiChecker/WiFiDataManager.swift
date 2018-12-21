//
//  AirportPlistParser.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/12/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Foundation


let AutoLogin = "AutoLogin"
let BSSIDList = "BSSIDList"
let Captive = "Captive"
let ChannelHistory = "ChannelHistory"
let Closed = "Closed"
let CollocatedGroup = "CollocatedGroup"
let Disabled = "Disabled"
let LastConnected = "LastConnected"
let Passpoint = "Passpoint"
let PersonalHotspot = "PersonalHotspot"
let PossiblyHiddenNetwork = "PossiblyHiddenNetwork"
let RoamingProfileType = "RoamingProfileType"
let SPRoaming = "SPRoaming"
let SSID = "SSID"
let SSIDString = "SSIDString"
let SecurityType = "SecurityType"
let SystemMode = "SystemMode"
let TemporarilyDisabled = "TemporarilyDisabled"

let Channel = "Channel"
let Timestamp = "Timestamp"

let LEAKY_AP_BSSID = "LEAKY_AP_BSSID"
let LEAKY_AP_LEARNED_DATA = "LEAKY_AP_LEARNED_DATA"

let PreferredOrder = "PreferredOrder"

class WiFiDataManager {
    
    
    fileprivate let systemConfigurationFolder = "/Library/Preferences/SystemConfiguration"
    fileprivate let airportPreferencesFile = "com.apple.airport.preferences.plist"
    
    fileprivate var _contentPlist: String = ""
    fileprivate var _rawContent: NSDictionary?
    fileprivate var _allNetworks: Dictionary<String,WiFiData> = [ : ]
    fileprivate var _knownNetworks: Array<WiFiData> = []
    fileprivate var _preferredOrder: Array<String> = []
    
    fileprivate var _openCount: Int = 0
    fileprivate var _wepCount: Int = 0
    fileprivate var _wpaCount: Int = 0
    
    var networks: Array<WiFiData> {
        get {
            return self._knownNetworks
        }
    }
    
    var preferredOrder: Array<String> {
        get {
            return self._preferredOrder
        }
    }
    
    fileprivate func findContentPlist() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.localDomainMask, true)
        return path[0]
    }
    
    fileprivate func findBool(_ value: AnyObject?) -> Bool {
        if value == nil {
            return false
        } else {
            return value as! Bool
        }
    }
    
    fileprivate func findInt(_ value: AnyObject?) -> Int {
        if value == nil {
            return -1
        } else {
            return value as! Int
        }
    }
    
    fileprivate func findString(_ value: AnyObject?) -> String {
        if value == nil {
            return ""
        } else {
            return value as! String
        }
    }
    
    fileprivate func findDate(_ value: AnyObject?) -> Date? {
        if value == nil {
            return nil
        } else {
            return (value as! Date)
        }
    }
    
    fileprivate func findData(_ value: AnyObject?) -> Data? {
        if value == nil {
            return nil
        } else {
            return (value as! Data)
        }
    }
    
    fileprivate func findBSSIDList(_ value: AnyObject?) -> Array<BSSIDData>? {
        var bssidList = Array<BSSIDData>()
        if (value == nil) {
            return nil
        } else {
            let arr: Array = value as! Array<Dictionary<String,AnyObject>>
            for dict in arr {
                let bssid = BSSIDData()
                bssid.LEAKY_AP_BSSID = findString(dict[LEAKY_AP_BSSID])
                bssid.LEAKY_AP_LEARNED_DATA = findData(dict[LEAKY_AP_LEARNED_DATA])!
                bssidList.append(bssid)
            }
        }
        return bssidList
    }
    
    fileprivate func findChannelHistory(_ value: AnyObject?) -> Array<ChannelData>? {
        
        var channelHistory = Array<ChannelData>()
        if value == nil {
            return nil
        } else {
            let arr: Array = value as! Array<Dictionary<String,AnyObject>>
            for dict in arr {
                let chan = ChannelData()
                chan.Channel = findInt(dict[Channel])
                chan.Timestamp = findDate(dict[Timestamp])
                
                channelHistory.append(chan)
            }
        }
        return channelHistory
        
    }
    
    fileprivate func findCollocatedGroup(_ value: AnyObject?) -> Array<String>? {
        var collocatedGroup = Array<String>()
        if (value == nil) {
            return nil
        } else {
            let arr: Array = value as! Array<String>
            for str in arr {
                collocatedGroup.append(str)
            }
        }
        
        return collocatedGroup
    }
    
    init() {
        populate(systemConfigurationFolder+"/"+airportPreferencesFile)
    }
    
    init(_ fileName: String) {
        populate(fileName)
    }
    
    fileprivate func cleanup() {
        _contentPlist = ""
        _rawContent = nil
        _allNetworks.removeAll()
        _knownNetworks.removeAll()
        _preferredOrder.removeAll()
        
        _openCount = 0
        _wepCount = 0
        _wpaCount = 0
    }
    
    func reloadWithFile(_ fileName: String) {
        cleanup()
        populate(fileName)
    }
    
    func reloadSystemConfiguration() {
        cleanup()
        populate(systemConfigurationFolder+"/"+airportPreferencesFile)
    }
    
    // Load data
    fileprivate func populate(_ fileName: String) {
        _rawContent = NSDictionary(contentsOfFile: fileName)
        _openCount = 0
        _wepCount = 0
        _wpaCount = 0
        
        let knownNetworks: Dictionary = (_rawContent!["KnownNetworks"] as? Dictionary<String,AnyObject>)!
        for (key, valueDict) in knownNetworks {
            //print("key: \(key)")
            //print("value: \(valueDict)")
            let value = valueDict as! Dictionary<String,AnyObject>
            let wifidata = WiFiData(key)
            wifidata.AutoLogin = findBool(value[AutoLogin])
            wifidata.BSSIDList = findBSSIDList(value[BSSIDList])
            wifidata.Captive = findBool(value[Captive])
            wifidata.ChannelHistory = findChannelHistory(value[ChannelHistory])
            wifidata.Closed = findBool(value[Closed])
            wifidata.CollocatedGroup = findCollocatedGroup(value[CollocatedGroup])
            wifidata.Disabled = findBool(value[Disabled])
            wifidata.LastConnected = findDate(value[LastConnected])
            wifidata.Passpoint = findBool(value[Passpoint])
            wifidata.PersonalHotspot = findBool(value[PersonalHotspot])
            wifidata.PossiblyHiddenNetwork = findBool(value[PossiblyHiddenNetwork])
            wifidata.RoamingProfileType = findString(value[RoamingProfileType])
            wifidata.SecurityType = findString(value[SecurityType])
            wifidata.SPRoaming = findBool(value[SPRoaming])
            wifidata.SSID = findData(value[SSID])!
            wifidata.SSIDString = findString(value[SSIDString])
            wifidata.SystemMode = findBool(value[SystemMode])
            wifidata.TemporarilyDisabled = findBool(value[TemporarilyDisabled])
            
            _knownNetworks.append(wifidata)
            _allNetworks[key] = wifidata
            
            if (wifidata.SecurityType.hasPrefix("Open")) {
                _openCount += 1
                wifidata.SecurityTypeInt = 0
            } else if (wifidata.SecurityType.hasPrefix("WE")) {
                _wepCount += 1
                wifidata.SecurityTypeInt = 10
            } else if (wifidata.SecurityType.hasPrefix("WP")) {
                _wpaCount += 1
                wifidata.SecurityTypeInt = 100
            }
                
        }
        
        let preferredOrder: Array = (_rawContent!["PreferredOrder"] as? Array<String>)!
        for wifissid in preferredOrder {
            _preferredOrder.append(wifissid)
        }
        
        // Loop the preferredOrder keys and set the value on the wifiid
        var count = 0
        for wifidatakey in _preferredOrder {
            let wifidata: WiFiData = _allNetworks[wifidatakey]!
            wifidata.PreferredOrder = count
            count += 1
        }
        
        // Find all the data objects
        for wifidata in _knownNetworks {
            // loop through any collocated groups
            if wifidata.CollocatedGroup != nil {
                // for each group, look up the ssid and last connected details
                for cg in wifidata.CollocatedGroup! {
                    let dexists: WiFiData? = _allNetworks[cg]
                    if dexists != nil {
                        let d: WiFiData = dexists!
                        wifidata.CollocatedGroupDetails.append(CollocatedGroupData(cg, ssid: d.SSIDString, secure: !d.SecurityType.hasPrefix("Open"), lastConnected: d.LastConnected))
                    } else {
                        // If we don't know what network it is (been deleted) then just display it here
                        let ssid = parseWiFiSSID(cg)
                        wifidata.CollocatedGroupDetails.append(CollocatedGroupData(cg, ssid: ssid, secure: false, lastConnected: nil))
                    }
                }
            }
        }
        
    }
    
    func wifiData(_ forKey: String) -> WiFiData {
        let data: WiFiData = self._allNetworks[forKey]!
        return data
    }
    
    func openCount() -> Int {
        return _openCount
    }
    
    func wepCount() -> Int {
        return _wepCount
    }
    
    func wpaCount() -> Int {
        return _wpaCount
    }

    
    func sort(_ sortDescriptors: Array<NSSortDescriptor>) {
        
        //let sortDescriptor: NSSortDescriptor = sortDescriptors[0]
        for sortDescriptor in sortDescriptors {
            let sortBy: String = sortDescriptor.key!
            let sortAscending: Bool = sortDescriptor.ascending
            switch sortBy {
            case LastConnected:
                _knownNetworks.sort(by: {
                    var result = false
                    if ($0.LastConnected == nil && $1.LastConnected == nil) {
                        result = ($0.SSIDString).caseInsensitiveCompare($1.SSIDString) == .orderedAscending
                    } else if ($0.LastConnected == nil) {
                        result = false
                    } else if ($1.LastConnected == nil) {
                        result = true
                    } else {
                        let compResult = $0.LastConnected!.compare($1.LastConnected! as Date)
                        if compResult == ComparisonResult.orderedAscending {
                            result = false
                        } else {
                            result = true
                        }
                    }
                    if sortAscending { return result }
                    else { return !result }
                })
                break
            case SecurityType:
                _knownNetworks.sort(by: {
                    if (sortAscending) {
                        return $0.SecurityTypeInt >= $1.SecurityTypeInt
                    } else {
                        return $0.SecurityTypeInt < $1.SecurityTypeInt
                    }
                })
                break
            case PreferredOrder:
                _knownNetworks.sort(by: {
                    if (sortAscending) {
                        return $0.PreferredOrder < $1.PreferredOrder
                    } else {
                        return $0.PreferredOrder > $1.PreferredOrder
                    }
                })
                break
            case SSIDString:
                _knownNetworks.sort(by: {
                    if (sortAscending) {
                        return ($0.SSIDString).caseInsensitiveCompare($1.SSIDString) == .orderedAscending
                    } else {
                        return ($0.SSIDString).caseInsensitiveCompare($1.SSIDString) == .orderedDescending
                    }
                })
                break
            default:
                _knownNetworks.sort(by: {
                    if (sortAscending) {
                        return ($0.SSIDString).caseInsensitiveCompare($1.SSIDString) == .orderedAscending
                    } else {
                        return ($0.SSIDString).caseInsensitiveCompare($1.SSIDString) == .orderedDescending
                    }
                })
            }
        }
    }
    
    func dateAtRow(_ row: Int, key: String) -> Date? {
        var response: Date?
        switch key {
        case LastConnected:
            response = _knownNetworks[row].LastConnected as Date?
            break
        default:
            response = nil
        }
        return response
    }
    
    func stringAtRow(_ row: Int, key: String) -> String? {
        var response: String?
        switch key {
        case AutoLogin:
            response = _knownNetworks[row].AutoLogin.description
            break
        case Captive:
            response = _knownNetworks[row].Captive.description
            break
        case Closed:
            response = _knownNetworks[row].Closed.description
            break
        case Disabled:
            response = _knownNetworks[row].Disabled.description
            break
        case LastConnected:
            response = _knownNetworks[row].LastConnected?.description
            break
        case Passpoint:
            response = _knownNetworks[row].Passpoint.description
            break
        case PersonalHotspot:
            response = _knownNetworks[row].PersonalHotspot.description
            break
        case PossiblyHiddenNetwork:
            response = _knownNetworks[row].PossiblyHiddenNetwork.description
            break
        case RoamingProfileType:
            response = _knownNetworks[row].RoamingProfileType
            break
        case SecurityType:
            response = _knownNetworks[row].SecurityType
            break
        case SPRoaming:
            response = _knownNetworks[row].SPRoaming.description
            break
        case SSID:
            response = _knownNetworks[row].SSID.description
            break
        case SSIDString:
            response = _knownNetworks[row].SSIDString
            break
        case SystemMode:
            response = _knownNetworks[row].SystemMode.description
            break
        case TemporarilyDisabled:
            response = _knownNetworks[row].TemporarilyDisabled.description
            break
        default:
            response = ""
        }
        return response
    }
    
    fileprivate func appendDetail(_ first: Bool, note: String) -> (Bool, String) {
        var response = ""
        if first {
            response = note
        } else {
            response = ", "+note
        }
        return (false, response)
    }
    
    func detailsAtRow(_ row: Int) -> String? {
        let data = _knownNetworks[row]
        var first = true
        var response = ""
        var detailResponse = ""
        if data.AutoLogin {
            (first, response) = appendDetail(first, note:AutoLogin)
            detailResponse += response
        }
        if data.Captive {
            (first, response) = appendDetail(first, note:Captive)
            detailResponse += response
        }
        if data.Closed {
            (first, response) = appendDetail(first, note:Closed)
            detailResponse += response
        }
        if data.Disabled {
            (first, response) = appendDetail(first, note:Disabled)
            detailResponse += response
        }
        if data.Passpoint {
            (first, response) = appendDetail(first, note:Passpoint)
            detailResponse += response
        }
        if data.PersonalHotspot {
            (first, response) = appendDetail(first, note:PersonalHotspot)
            detailResponse += response
        }
        if data.PossiblyHiddenNetwork {
            (first, response) = appendDetail(first, note:PossiblyHiddenNetwork)
            detailResponse += response
        }
        if data.SPRoaming {
            (first, response) = appendDetail(first, note:SPRoaming)
            detailResponse += response
        }
        if data.SystemMode {
            (first, response) = appendDetail(first, note:SystemMode)
            detailResponse += response
        }
        if data.TemporarilyDisabled {
            (first, response) = appendDetail(first, note:TemporarilyDisabled)
            detailResponse += response
        }
        
        return detailResponse
    }
    
    // Convert the airport plist id to an SSID
    func parseWiFiSSID(_ appleWiFiID: String) -> String {
        // Parse the Apple Plist Key into the SSID
        if (appleWiFiID.hasPrefix("wifi.ssid.")) {
            let index = appleWiFiID.index(appleWiFiID.startIndex, offsetBy: 10)
            let preSSID = String(appleWiFiID[index...])
            // preSSID now should look like <65776545 88776655>
            // This is now raw ascii that we'll need to convert to a string
            var parsedSSID = ""
            var intSSID = ""
            var count = 0
            for ch in preSSID {
                count = count + 1
                if (ch == "<") {
                    // Starting char
                    count = 0
                } else if (ch == " ") {
                    // Skip
                    count = 0
                } else if (ch == ">") {
                    // Last char
                    count = 0
                } else {
                    if count == 1 {
                        intSSID = "\(ch)"
                    } else if count == 2 {
                        intSSID = "\(intSSID)\(ch)"
                        count = 0
                        let asciiToChar = Character(UnicodeScalar(Int(intSSID, radix:16)!)!)
                        parsedSSID = "\(parsedSSID)\(asciiToChar)"
                    }
                }
            }
            return parsedSSID
        }
        return appleWiFiID
    }

    
    fileprivate func dateToString(_ d: Date?) -> String {
        if d == nil {
            return ""
        }
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: d!)
    }
    
}
