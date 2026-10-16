//
//  ScreenDetector.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 26/02/2024.
//  Adapted from https://stackoverflow.com/questions/14507312/how-can-you-detect-the-connection-and-disconnection-of-external-monitors-on-the
//

import Cocoa

class ScreenDetector {
    
    var timer: Timer?

    // CoreGraphics delivers reconfiguration callbacks on the main run loop,
    // so scheduling the timer here puts it on the main run loop too
    static let callback: CGDisplayReconfigurationCallBack = { (displayId, flags, userInfo) in
        guard let opaque = userInfo else {
            return
        }
        
        let passedSelf = Unmanaged<ScreenDetector>.fromOpaque(opaque).takeUnretainedValue()
        
        if flags.contains(.addFlag) || flags.contains(.removeFlag) || flags.contains(.enabledFlag) || flags.contains(.disabledFlag) {
            if passedSelf.timer?.isValid != true {
                passedSelf.timer = Timer.scheduledTimer(timeInterval: 1.0, target: passedSelf, selector: #selector(ensurePreferences), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func ensurePreferences() {
        Stillcolor.applySavedPreferences()
        self.timer?.invalidate()
    }
    

    func addObservers() {
        let userData = Unmanaged<ScreenDetector>.passUnretained(self).toOpaque()
        CGDisplayRegisterReconfigurationCallback(ScreenDetector.callback, userData)
    }
    
    func removeObservers() {
        let userData = Unmanaged<ScreenDetector>.passUnretained(self).toOpaque()
        CGDisplayRemoveReconfigurationCallback(ScreenDetector.callback, userData)
    }
}
