//
//  Constants.swift
//  MUI 26
//

import Foundation

/// One place for every value that is referred to from more than one file.
///
/// The scene and entity names below have to match what you named things in
/// Reality Composer Pro. If you rename an entity there, rename it here too --
/// nothing else in the project spells these strings out.
struct Constants {
    // Scene identifiers, handed to openWindow / dismissWindow / openImmersiveSpace.
    static let podiumWindowIdentifier = "PodiumView"
    static let objectVolumeIdentifier = "VirtualObjectView"
    static let exhibitionSpaceIdentifier = "VirtualExhibitionView"

    // Window and volume sizes.
    static let windowWidth: CGFloat = 500
    static let windowHeight: CGFloat = 300
    static let volumeSize: CGFloat = 100
    static let hoverEffectSize: CGFloat = 60

    // Reality Composer Pro scenes, i.e. the .usda files in MUIContent.rkassets.
    static let exhibitionSceneName = "Exhibition"
    static let objectSceneName = "Object"

    // Entity names inside the Exhibition scene are built by `Plinth`,
    // `Podium` and `Artefact`, since each of those exists once per side.

    /// How far the podium sinks while an artefact is being carried, in metres.
    static let podiumDip: Float = -0.1

    /// How long a released object takes to ease back to where it started.
    static let returnDuration: TimeInterval = 0.4
}
