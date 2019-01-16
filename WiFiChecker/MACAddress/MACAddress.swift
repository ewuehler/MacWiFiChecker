//
//  MACAddress.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 1/13/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import Foundation

class MACAddress {
    var Registry: String
    var Assignment: String
    var OrgName: String
    var OrgAddress: String
    
    init(registry: String, assignment: String, orgName: String, orgAddress: String) {
        
        func normalize(_ str: String) -> String {
            var out: String = str
            if (out.hasPrefix("\"")) {
                let start = out.index(out.startIndex, offsetBy: 1)
                out = String(out[start...])
                if (out.hasSuffix("\"")) {
                    let end = out.index(out.endIndex, offsetBy:-1)
                    out = String(out[..<end])
                }
            }
            return out
        }
        
        self.Registry = registry
        self.Assignment = assignment
        self.OrgName = normalize(orgName)
        self.OrgAddress = normalize(orgAddress)
    }
    
}
