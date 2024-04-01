//
//  IORegistryPropertyHelper.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 28/03/2024.
//

import Foundation

class IORegistryPropertyHelper {
    static func CFValueForKey(_ propKey: String, _ entry: io_registry_entry_t) -> CFTypeRef! {
        return IORegistryEntrySearchCFProperty(entry, kIOServicePlane, propKey as CFString, kCFAllocatorDefault, IOOptionBits(0))
    }
    
    static func bool(_ key: String, _ entry: io_registry_entry_t) -> Bool? {
        if let val = CFValueForKey(key, entry) {
            return val as? Bool
        }
        
        return nil
    }
    
    static func string(_ key: String, _ entry: io_registry_entry_t) -> String? {
        if let val = CFValueForKey(key, entry) {
            return val as! NSString as String
        }
        
        return nil
    }
    
    static func array(_ key: String, _ entry: io_registry_entry_t) -> NSMutableArray? {
        return CFValueForKey(key, entry) as? NSMutableArray
    }
}
