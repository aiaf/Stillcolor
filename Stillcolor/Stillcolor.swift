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

enum PreferenceKey {
    static let disableDithering = "disableDithering"
    static let disableUniformity2D = "disableUniformity2D"

    // @AppStorage defaults aren't written to UserDefaults, so register the same defaults
    // for code that reads UserDefaults directly
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            disableDithering: true,
            disableUniformity2D: false,
        ])
    }
}

class Stillcolor {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IOKit")
    private static var hasShownAlert = false

    static func applySavedPreferences() {
        let defaults = UserDefaults.standard
        enableDisableDithering(defaults.bool(forKey: PreferenceKey.disableDithering))
        enableDisableUniformity2D(defaults.bool(forKey: PreferenceKey.disableUniformity2D))
    }
    
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
            let message = "Could not query services matching IOMobileFramebufferAP: \(String(cString: mach_error_string(ret)))"
            logger.error("\(message, privacy: .public)")
            self.alert(message)
            return
        }
        
        // Some code portions here are from the Monitor Control project, thanks!
        // An empty match still returns KERN_SUCCESS with a valid iterator, so count matches ourselves
        var matchedServices = 0
        var failures: [String] = []
        
        while true {
            let service = IOIteratorNext(iterator)
            if service == IO_OBJECT_NULL {
                break
            }
            defer { IOObjectRelease(service) }
            matchedServices += 1
            
            let displayIsExternal = IORegistryPropertyHelper.bool("external", service) ?? false
            let displayDescription = displayIsExternal ? "external" : "embedded"
            
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
                
                // CFEqual traps on NULL, so a missing property must be checked first
                if let currentVal = IORegistryPropertyHelper.CFValueForKey(propKey, service), CFEqual(newVal, currentVal) {
                    continue
                }
                
                let ret = IORegistryEntrySetCFProperty(service, propKey as CFString, newVal)
                let result = String(cString: mach_error_string(ret))
                
                if ret == KERN_SUCCESS {
                    logger.info("Set I/O Registry property \(propKey, privacy: .public) = \(String(describing: newVal), privacy: .public) on \(displayDescription, privacy: .public) display")
                } else {
                    logger.error("Failed to set I/O Registry property \(propKey, privacy: .public) = \(String(describing: newVal), privacy: .public) on \(displayDescription, privacy: .public) display -> \"\(result, privacy: .public)\"")
                    failures.append("\(propKey) on \(displayDescription) display: \(result)")
                }
            }
        }

        if matchedServices == 0 {
            let message = "No compatible displays found (no services matching IOMobileFramebufferAP). Stillcolor requires an Apple silicon Mac."
            logger.error("\(message, privacy: .public)")
            self.alert(message)
        } else if !failures.isEmpty {
            self.alert("Could not change display settings:\n" + failures.joined(separator: "\n"))
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
    
    // Shows at most one alert per launch so repeated display reconfigurations don't stack modals
    static func alert(_ message: String) {
        if hasShownAlert {
            return
        }
        hasShownAlert = true

        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Stillcolor Issue"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .critical
            // Menu bar apps aren't active by default, so bring the alert to the front
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }
    
    //MARK: - CF utils
    
    static func CFBooleanFromBool(_ value : Bool) -> CFBoolean {
        return value ? kCFBooleanTrue : kCFBooleanFalse
    }
}
