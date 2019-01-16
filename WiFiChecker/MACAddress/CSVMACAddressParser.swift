//
//  CSVParser.swift
//  WiFiChecker
//
//  Created by Eric Wuehler on 1/13/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import Foundation

let Registry = "Registry"
let Assignment = "Assignment"
let OrgName = "Organization Name"
let OrgAddress = "Organization Address"

class CSVMACAddressParser {
    
    private let headers: [String] = [Registry, Assignment, OrgName, OrgAddress]
    
    private var mal: [String:MACAddress] = [:]
    private var mam: [String:MACAddress] = [:]
    private var mas: [String:MACAddress] = [:]
    
    init() {
        load()
    }

    func orgName(by mac: String) -> String? {
        let raw = mac.replacingOccurrences(of: ":", with: "", options: NSString.CompareOptions.literal, range:nil)
        let oui24: String = String(raw.dropLast(6))
        let oui28: String = String(raw.dropLast(5))
        let oui36: String = String(raw.dropLast(3))
//        print("Small: \(oui36), Medium: \(oui28), Large: \(oui24)")
        let m36 = mas[oui36]
        if m36 != nil {
//            print("Small: \(String(describing: m36))")
            return m36?.OrgName
        }
        let m28 = mam[oui28]
        if m28 != nil {
//            print("Medium: \(String(describing: m28))")
            return m28?.OrgName
        }
        let m24 = mal[oui24]
        if m24 != nil {
            return m24?.OrgName
        } else {
            return "[Unknown]"
        }
    }
    
    
    private func load() {
        // TODO: maybe pull these down in preferences once a week or on demand
        // and not have them embedded in the binary...
        load(path: Bundle.main.path(forResource: "mal", ofType: "csv")!, which: &mal)
        load(path: Bundle.main.path(forResource: "mam", ofType: "csv")!, which: &mam)
        load(path: Bundle.main.path(forResource: "mas", ofType: "csv")!, which: &mas)
    }
    
    private func load(path: String, which: inout [String:MACAddress]) {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8) //.replacingOccurrences(of: "\r\n", with: "\n")
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                let tline = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if (tline.count > 0) {
                    let result = split(tline, separator:",")
                    if (result.count != 4) {
                        print("Invalid # of results from the split: \(result)")
                    } else {
                        let m = MACAddress(registry: result[0], assignment: result[1], orgName: result[2], orgAddress: result[3])
                        which[m.Assignment] = m
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    private func checkQuotes(_ string: String) -> Bool {
        return string.components(separatedBy: "\"").count % 2 == 0
    }
    
    private func split(_ string: String, separator: String) -> [String] {
        let start = string.components(separatedBy: separator)
        var result = [String]()
        for string in start {
            guard let record = result.last, checkQuotes(record) == true else {
                result.append(string)
                continue
            }
            result.removeLast()
            let last = record + separator + string
            result.append(last)
        }
        return result
    }
    
}
