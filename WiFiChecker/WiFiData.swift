//
//  WiFiData.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/12/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//

import Foundation
import AppKit


class WiFiData: NSObject {
    
    var WiFiID: String = "InvalidID"
    var AddedBy: Int = -1
    var AutoLogin: Bool = false
    var BSSIDList: Array<BSSIDData>? = nil
    var Captive: Bool = false
    var CaptiveBypass: Bool = false
    var ChannelHistory: Array<ChannelData>? = nil
    var CollocatedGroup: Array<String>? = nil
    var Closed: Bool = false
    var Disabled: Bool = false
    var LastConnected: Date? = nil
    var NetworkWasCaptive: Bool = false
    var Passpoint: Bool = false
    var PersonalHotspot: Bool = false
    var PossiblyHiddenNetwork: Bool = false
    var RoamingProfileType: String = ""
    var ShareMode: Int = -1
    var SPRoaming: Bool = false
    var SSID: Data = Data() // Base64 Encoded SSID String
    var SSIDString: String = ""
    var SecurityType: String = ""
    var SystemMode: Bool = false
    var TemporarilyDisabled: Bool = false
    var UserRole: Int = -1
    
    var CollocatedGroupDetails: Array<CollocatedGroupData> = []
    var SecurityTypeInt: Int = 0
    var PreferredOrder: Int = 0
    
    init(_ id: String) {
        self.WiFiID = id
    }
    
    func lastConnectedString() -> String {
        if LastConnected == nil {
            return ""
        }
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: LastConnected!)
    }

    func securityImage() -> NSImage? {
        var image: NSImage? = nil
        if SecurityType.hasPrefix("WE") {
            image = NSImage(named: "locked")
        } else if SecurityType.hasPrefix("WP") {
            image = NSImage(named: "locked")
        } else {
            image = NSImage(named: "unlocked")
        }
        return image
    }
    
    func sortChannelData(_ sortDescriptors: Array<NSSortDescriptor>) -> Array<ChannelData>{
        
        if self.ChannelHistory == nil {
            return []
        }
        
        let ch:Array<ChannelData> = self.ChannelHistory!
        
        var sortedArray:Array<ChannelData> = []
        
        let sortDescriptor = sortDescriptors[0]
        let sortBy: String = sortDescriptor.key!
        let sortAscending: Bool = sortDescriptor.ascending
        
        
        if sortBy == Channel {
            if sortAscending {
                sortedArray = ch.sorted { cd0, cd1 in
                    cd0.Channel <= cd1.Channel
                }
                
            } else {
                sortedArray = ch.sorted { cd0, cd1 in
                    cd0.Channel > cd1.Channel
                }
            }
        }
        
        if sortBy == Timestamp {
            if sortAscending {
                sortedArray = ch.sorted {
                    t0, t1 in
                    t0.Timestamp! <= t1.Timestamp!
                }
            } else {
                sortedArray = ch.sorted {
                    t0, t1 in
                    t0.Timestamp! > t1.Timestamp!
                }
            }
        }
        return sortedArray
    }

}

class ChannelData: NSObject {
    var Channel: Int = -1
    var Timestamp: Date? = nil

    func timestampString() -> String {
        if Timestamp == nil {
            return ""
        }
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: Timestamp!)
    }
    
}

class BSSIDData: NSObject {
    var LEAKY_AP_BSSID: String = ""
    var LEAKY_AP_LEARNED_DATA: Data = Data() // No clue what this means yet
    var Manufacturer: String = ""
    var normalizedMAC: String? = nil
    var normalizedOUI: String? = nil
    var SSID: String = ""
    
    fileprivate func normalizedBSSID() -> String {
        
        if normalizedMAC != nil {
            return normalizedMAC!
        }
        // convert 0:0:0 to 00:00:00 kinda stuff
        let bssdArr = LEAKY_AP_BSSID.components(separatedBy: ":")
        // Now rebuild string
        var normalizedBSSID = ""
        var first = true
        
        for x in bssdArr {
            if !first {
                normalizedBSSID = normalizedBSSID.appending(":")
            }
            first = false
            if x.count == 1 {
                normalizedBSSID = normalizedBSSID.appending("0\(x.uppercased())")
            } else {
                normalizedBSSID = normalizedBSSID.appending(x.uppercased())
            }
        }
        normalizedMAC = normalizedBSSID
        
        return normalizedMAC!
    }
    
    func mac() -> String {
        return normalizedBSSID()
    }
    
    func oui() -> String {
        if normalizedOUI != nil {
            return normalizedOUI!
        }
        let mac = self.mac()
        let index: String.Index = mac.index(mac.startIndex, offsetBy: 8)
//        normalizedOUI = mac.substring(to: index)
        normalizedOUI = String(mac[..<index])
        return normalizedOUI!
    }
}

class CollocatedGroupData: NSObject {
    var id: String
    var ssid: String
    var secure: Bool
    var lastConnected: Date?
    
    init(_ id: String, ssid: String, secure: Bool, lastConnected: Date?) {
        self.id = id
        self.ssid = ssid
        self.secure = secure
        self.lastConnected = lastConnected
    }
    
    func lastConnectedString() -> String {
        if self.lastConnected == nil {
            return "Never"
        }
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: self.lastConnected!)
    }
}

extension NSImage {
    func tinted(color:NSColor) -> NSImage {
        let size        = self.size
        let imageBounds = NSMakeRect(0, 0, size.width, size.height)
        let copiedImage = self.copy() as! NSImage
        
        copiedImage.lockFocus()
        color.set()
        __NSRectFillUsingOperation(imageBounds, .sourceAtop)
        copiedImage.unlockFocus()
        
        return copiedImage
    }
}
