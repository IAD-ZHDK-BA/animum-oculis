//
//  Podium.swift
//  MUI 26
//

import Foundation

/// Which of the two plinths in the scene we mean.
///
/// Each plinth is a self-contained little stage: its own podium, its own
/// artefact, its own label, its own reveal timeline. Tapping one does nothing
/// to the other.
enum Plinth: String, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"

    var id: String {
        return rawValue
    }

    /// The whole plinth. Everything standing on it is somewhere below this
    /// entity, which is how we tell which plinth a carried object came from.
    var containerName: String {
        return "Plinth_\(rawValue)"
    }

    /// The group that carries the tap gesture and the reveal behaviour.
    var podiumName: String {
        return "Podium_\(rawValue)"
    }

    /// The empty entity the label hangs on.
    var uiAnchorName: String {
        return "UI_Anchor_\(rawValue)"
    }

    /// The particle emitter above this plinth.
    var sparksName: String {
        return "Sparks_\(rawValue)"
    }

    /// What the switcher on the onboarding window shows.
    var title: String {
        return rawValue
    }
}

/// The plinth's shape. Same idea as `Artefact`: a value type whose `modelName`
/// names both the entity in Reality Composer Pro and the image set in
/// Assets.xcassets, so one string does both jobs.
///
/// Both plinths carry both shapes; only the selected one is enabled, which is
/// why the entity name needs the side appended to it.
struct Podium: Identifiable, Hashable {
    let id = UUID()

    let title: String
    let modelName: String

    /// e.g. "Podium_A" on the left plinth is the entity "Podium_A_Left".
    func entityName(on plinth: Plinth) -> String {
        return "\(modelName)_\(plinth.rawValue)"
    }
}

let podiums = [
    Podium(title: "Square", modelName: "Podium_A"),
    Podium(title: "Round", modelName: "Podium_B")
]
