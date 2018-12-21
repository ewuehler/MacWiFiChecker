//
//  TouchBarExtensions.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 2/13/17.
//  Copyright © 2017 Eric Wuehler. All rights reserved.
//


import AppKit


extension NSTouchBar.CustomizationIdentifier {
    
    static let hotspotBar = "com.ciretose.wifi.HotspotBar"
}

extension NSTouchBarItem.Identifier {
    
    static let totalHotspots = NSTouchBarItem.Identifier("com.ciretose.wifi.TotalHotspots")
    static let openHotspots = NSTouchBarItem.Identifier("com.ciretose.wifi.OpenHotspots")
    static let wepHotspots = NSTouchBarItem.Identifier("com.ciretose.wifi.WEPHotspots")
    static let wpaHotspots = NSTouchBarItem.Identifier("com.ciretose.wifi.WPAHotspots")
    
}

