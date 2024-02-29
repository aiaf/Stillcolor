//
//  ScreenDetector.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 26/02/2024.
//  Adapted from https://stackoverflow.com/questions/14507312/how-can-you-detect-the-connection-and-disconnection-of-external-monitors-on-the
//

import Cocoa

class ScreenDetector {

    static let callback: CGDisplayReconfigurationCallBack = { (displayId, flags, userInfo) in
        guard let opaque = userInfo else {
            return
        }
        let mySelf = Unmanaged<ScreenDetector>.fromOpaque(opaque).takeUnretainedValue()
        
        if flags.contains(.addFlag)  {
            IOMFBShiv.enableDisableDithering(UserDefaults.standard.bool(forKey: "disableDithering"))
        }
    }

    func addObervers() {
        let userData = Unmanaged<ScreenDetector>.passUnretained(self).toOpaque()
        CGDisplayRegisterReconfigurationCallback(ScreenDetector.callback, userData)
    }
    
    func removeObservers() {
        let userData = Unmanaged<ScreenDetector>.passUnretained(self).toOpaque()
        CGDisplayRemoveReconfigurationCallback(ScreenDetector.callback, userData)
    }

}
