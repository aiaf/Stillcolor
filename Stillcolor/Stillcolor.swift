//
//  Stillcolor.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 26/02/2024.
//


import AppKit
import os

enum DisplayLocation {
    case All
    case Embedded
    case External
}

class Stillcolor {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IOKit")

    
    static func setPropertiesOnDisplayDriver(_ props : Dictionary<String, CFTypeRef>, _ targetDisplayLocation: DisplayLocation = .All) {
        var iterator = io_iterator_t()
        defer {
            IOObjectRelease(iterator);
        }
        
        /*
            IOMobileFramebufferAP is an ancestor of both AppleCLCD2 and IOMobileFramebufferShim.
            This allows us to construct 1 matching criteria for both objects
            IORegistryEntry:IOService:IOMobileFramebuffer:IOMobileFramebufferService:IOMobileFramebufferAP:UnifiedPipeline2:AppleCLCD2
            IORegistryEntry:IOService:IOMobileFramebuffer:IOMobileFramebufferService:IOMobileFramebufferAP:UnifiedPipeline2:IOMobileFramebufferShim
         
            Not sure of the exact history but M2 MacBook Air and M2 Mac mini use AppleCLCD2 (so do M1 counterparts, probably)
            While an M3 Max MBP for example uses IOMobileFramebufferShim.
            Can IOMobileFramebufferShim indicate a higher-end screen with certain attributes like PWM? Need to investigate.
         */
        let ret = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOMobileFramebufferAP"), &iterator)
        
        if iterator == IO_OBJECT_NULL || ret != KERN_SUCCESS {
            let message = "Could not find services matching IOMobileFramebufferAP"
            logger.error("\(message)")
            self.alert(message)
            return
        }
        
        var service: io_service_t = IO_OBJECT_NULL
        // Some code portions here are from the Monitor Control project, thanks!
        let name = UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
        defer {
            name.deallocate()
        }
        
        while true {
            service = IOIteratorNext(iterator)
            defer { IOObjectRelease(service) }
            
            if service == 0 {
                break
            }
            
            guard IORegistryEntryGetName(service, name) == KERN_SUCCESS else {
                continue
            }
            
            let displayIsExternal = IORegistryPropertyHelper.bool("external", service) ?? false
            
            if displayIsExternal {
                if targetDisplayLocation == .Embedded {
                    continue
                }
            } else if targetDisplayLocation == .External {
                continue
            }
 
            // IORegistryEntrySetCFProperties does not work properly here- only the first porperty gets modified
            // So we need to set them individually
            for (propKey, newVal) in props {
                
                if CFEqual(newVal, IORegistryPropertyHelper.CFValueForKey(propKey, service)) {
                    continue
                }
                
                let ret = IORegistryEntrySetCFProperty(service, propKey as CFString, newVal)
                
                logger.info("Setting I/O Registry property \(String(propKey)) = \(String(describing: newVal)) on \(displayIsExternal ? "external": "embedded") display -> \"\(String(cString: mach_error_string(ret)))\"")
            }
        }
    }

    static func enableDisableDithering(_ disable: Bool) {
        setPropertiesOnDisplayDriver([
            "enableDither": CFBooleanFromBool(!disable)
        ])
    }
    
    static func enableDisableUniformity2D(_ disable: Bool) {
        setPropertiesOnDisplayDriver([
            "uniformity2D": CFBooleanFromBool(!disable)
        ], .Embedded)
    }
    
    static func alert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Stillcolor Issue"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .critical
        alert.runModal()
    }
    
    //MARK: - CF utils
    
    static func CFBooleanFromBool(_ value : Bool) -> CFBoolean {
        return value ? kCFBooleanTrue : kCFBooleanFalse
    }
    
    static func CFNumberFromInteger(_ value: UInt32) -> CFNumber {
        return NSNumber(value: value) as CFNumber
    }
}
