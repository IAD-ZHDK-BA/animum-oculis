//
//  MUIApp.swift
//  MUI 26
//

import SwiftUI

@main
struct MUIApp: App {
    /// Made once, here, and handed to every scene below. One instance, one
    /// source of truth -- never make a second `AppState()` anywhere else.
    /// See `.environment(appState)` and `@Environment(AppState) var appState`.
    @State var appState = AppState()

    var body: some Scene {
        // 1. The onboarding window. No id: it is the one that opens on launch.
        WindowGroup {
            OnboardingView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: Constants.windowWidth, height: Constants.windowHeight)
        .windowResizability(.contentSize)

        // 2. A second window, to the right of the first, for picking the podium.
        WindowGroup(id: Constants.podiumWindowIdentifier) {
            PodiumView()
                .environment(appState)
        }
        .windowStyle(.plain)
        .defaultSize(width: Constants.windowWidth, height: Constants.windowHeight)
        .windowResizability(.contentSize)
        .defaultWindowPlacement { _, context in
            if let mainWindow = context.windows.first {
                return WindowPlacement(.trailing(mainWindow))
            }
            return WindowPlacement(.none)
        }

        // 3. A volume, to the left, showing the selected artefact on its own.
        //    A volume is a WindowGroup too -- only the style and size differ.
        WindowGroup(id: Constants.objectVolumeIdentifier) {
            VirtualObjectView()
                .environment(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(
            width: Constants.volumeSize,
            height: Constants.volumeSize * 0.5,
            depth: Constants.volumeSize * 0.5,
            in: .centimeters
        )
        .defaultWindowPlacement { _, context in
            if let mainWindow = context.windows.first {
                return WindowPlacement(.leading(mainWindow))
            }
            return WindowPlacement(.none)
        }

        // 4. The immersive space: the exhibition itself, 1.7 m in front of you.
        //    Only one space can be open at a time, which is why closing it
        //    takes no identifier.
        ImmersiveSpace(id: Constants.exhibitionSpaceIdentifier) {
            VirtualExhibitionView()
                .environment(appState)
                .onAppear {
                    appState.hasEnteredImmersiveSpace = true
                }
                .onDisappear {
                    appState.hasEnteredImmersiveSpace = false
                }
        }
    }
}
