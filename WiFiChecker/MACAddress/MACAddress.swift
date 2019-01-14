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
        self.Registry = registry
        self.Assignment = assignment
        self.OrgName = orgName
        self.OrgAddress = orgAddress
    }
}
