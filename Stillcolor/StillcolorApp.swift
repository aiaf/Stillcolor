//
//  StillcolorApp.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 25/02/2024.
//

import SwiftUI
import LaunchAtLogin

@main
struct Stillcolor: App {
    @AppStorage("disableDithering") var disableDithering: Bool = true
    
    var detector = ScreenDetector();
    
    init() {
        detector.addObervers()
        IOMFBShiv.enableDisableDithering(disableDithering)
    }
    
    var body: some Scene {
        MenuBarExtra(
            "Stillcolor",
            systemImage: "\(disableDithering  ? "livephoto.slash" : "livephoto")"
        ) {
            Toggle("Disable Dithering", isOn: .init(
                get: { disableDithering },
                set: {
                    disableDithering = $0
                    IOMFBShiv.enableDisableDithering(disableDithering)
                }
            ))
            Divider()
            LaunchAtLogin.Toggle()
            Divider()
            Button("Quit Stillcolor") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
