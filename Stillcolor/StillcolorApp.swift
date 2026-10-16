//
//  StillcolorApp.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 25/02/2024.
//

import SwiftUI
import LaunchAtLogin

@main
struct StillcolorApp: App {
    @AppStorage("disableDithering") var disableDithering: Bool = true
    @AppStorage("ditherExternalOnly") var ditherExternalOnly: Bool = false
    @AppStorage("disableUniformity2D") var disableUniformity2D: Bool = false

    var detector = ScreenDetector();

    init() {
        detector.addObervers()
        Stillcolor.enableDisableDithering(disableDithering, externalOnly: ditherExternalOnly)
        Stillcolor.enableDisableUniformity2D(disableUniformity2D)
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
                    Stillcolor.enableDisableDithering(disableDithering, externalOnly: ditherExternalOnly)
                }
            ))

            Toggle("External Displays Only", isOn: .init(
                get: { ditherExternalOnly },
                set: {
                    ditherExternalOnly = $0
                    Stillcolor.enableDisableDithering(disableDithering, externalOnly: ditherExternalOnly)
                }
            ))
            .disabled(!disableDithering)

            Divider()

            Toggle("Disable uniformity2D", isOn: .init(
                get: { disableUniformity2D },
                set: {
                    disableUniformity2D = $0
                    Stillcolor.enableDisableUniformity2D(disableUniformity2D)
                }
            ))
            
            Label {
                Text("(Experimental) Stop built-in display from\nusing lower brightness levels around the edges")
                    .font(.caption)
                    .fontWeight(.thin)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            } icon: {
            }
            
            Divider()
            LaunchAtLogin.Toggle()
            Divider()
            Button("Quit Stillcolor") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
