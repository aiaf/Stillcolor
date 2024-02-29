//
//  IOMFBShiv.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 26/02/2024.
//

import AppKit
import os

class IOMFBShiv {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "IOKit")

    static func enableDisableDithering(_ disableDither: Bool) {
        var iterator = io_iterator_t()
        /*
            IOMobileFramebufferAP is an ancestor of both AppleCLCD2 and IOMobileFramebufferShim.
            This allows us to construct 1 matching criterie for both objects
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
        
        var ioMessage: String;
        var client: io_connect_t = IO_OBJECT_NULL
        var service: io_service_t = IO_OBJECT_NULL
        // Some code portions here are from the Monitor Control project, thanks!
        let name = UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
        defer {
          name.deallocate()
        }
        while true {
            service = IOIteratorNext(iterator)
            
            guard IORegistryEntryGetName(service, name) == KERN_SUCCESS, service != MACH_PORT_NULL else {
                break
            }
            
            let nameString = String(cString: name)
            
            logger.info("\(nameString) service: \(String(format: "%x", service))")
            
            let kernReturn = IOServiceOpen(service, mach_task_self_, UInt32(kIOFBServerConnectType), &client)
            
            if kernReturn != KERN_SUCCESS {
                ioMessage = "IOServiceOpen failed on: \(String(cString: mach_error_string(kernReturn)))"
                logger.error("\(ioMessage)")
                self.alert(ioMessage)
                continue
            }
            
            logger.info("\(nameString) client: \(String(format: "%x", client))")
            
            let setPropRet = IORegistryEntrySetCFProperty(service, "enableDither" as CFString, disableDither ? kCFBooleanFalse : kCFBooleanTrue)
            ioMessage = "IORegistryEntrySetCFProperty returned \(setPropRet) -> \(String(cString: mach_error_string(setPropRet)))"
            logger.info("\(ioMessage)")
            
            if setPropRet != KERN_SUCCESS {
                logger.error("Failed to set enableDither to \(!disableDither) \(ioMessage)")
                self.alert(ioMessage)
            } else {
                logger.info("enableDither set to \(!disableDither)")
            }
            
            IOServiceClose(client)
            IOObjectRelease(service)
        }
        
        IOObjectRelease(iterator);
    }
    
    static func alert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Stillcolor Issue"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .critical
        alert.runModal()
    }
}
