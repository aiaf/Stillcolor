//
//  IORegistryPropertyHelper.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 28/03/2024.
//

import Foundation

class IORegistryPropertyHelper {
    static func CFValueForKey(_ propKey: String, _ entry: io_registry_entry_t) -> CFTypeRef? {
        return IORegistryEntrySearchCFProperty(entry, kIOServicePlane, propKey as CFString, kCFAllocatorDefault, IOOptionBits(0))
    }
    
    static func bool(_ key: String, _ entry: io_registry_entry_t) -> Bool? {
        return CFValueForKey(key, entry) as? Bool
    }
}
