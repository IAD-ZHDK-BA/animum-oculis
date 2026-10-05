//
//  AppState.swift
//  MUI 26
//

import SwiftUI

/// The single source of truth for the whole app.
///
/// One instance is made in `MUIApp` and handed to every scene with
/// `.environment(_:)`. Every view reads it back with
/// `@Environment(AppState.self)`, so a change here shows up everywhere at once
/// -- in the window, in the volume and in the immersive space.
///
/// `@Observable` is what makes that work: SwiftUI notices which properties a
/// view actually read and re-runs only those views when one of them changes.
@Observable
class AppState {
    /// Where the app is. Drives what the onboarding window shows.
    var phase: AppPhase = .welcome

    /// Which plinth the pickers are currently aimed at. The switcher on the
    /// onboarding window sets it; the podium window and the volume both follow.
    var editingPlinth: Plinth = .right

    /// What stands on each plinth, and what each plinth looks like. Both are
    /// keyed by side, so the two plinths are set independently.
    var selectedArtefacts: [Plinth: Artefact] = [
        .left: artefacts[3],    // the installation
        .right: artefacts[0]    // the cone
    ]

    var selectedPodiums: [Plinth: Podium] = [
        .left: podiums[0],
        .right: podiums[0]
    ]

    /// The artefact on the plinth currently being edited.
    ///
    /// A computed property with a getter *and* a setter, so a Picker can bind
    /// straight to it: reading gives that plinth's artefact, writing changes
    /// only that plinth. One picker, either side, depending on `editingPlinth`.
    var selectedArtefact: Artefact {
        get {
            selectedArtefacts[editingPlinth] ?? artefacts[0]
        } set {
            selectedArtefacts[editingPlinth] = newValue
        }
    }

    /// The same idea for the plinth's shape.
    var selectedPodium: Podium {
        get {
            selectedPodiums[editingPlinth] ?? podiums[0]
        } set {
            selectedPodiums[editingPlinth] = newValue
        }
    }

    /// Set from the immersive space's `.onAppear` / `.onDisappear`. The
    /// onboarding button reads it to decide between "Open Planning" and "Leave".
    var hasEnteredImmersiveSpace = false

    /// Which plinth's object is being carried right now, or nil if none is.
    ///
    /// An optional rather than a Bool, because we need to know *which* one: only
    /// that plinth sinks, and only its label fades out.
    var heldPlinth: Plinth?

    /// True while the two plinths' objects are touching. The sparks are driven
    /// from RealityKit; this mirrors the same fact into SwiftUI so a window
    /// could show it too.
    var isInstallationActive = false
}
