//
//  Artefact.swift
//  MUI 26
//

import Foundation

/// One thing on show. A struct, because an artefact is a value: two artefacts
/// with the same contents are the same artefact, and copying one cannot
/// accidentally change the other.
///
/// `modelName` is the bridge into Reality Composer Pro -- it has to be spelled
/// exactly like the entity in the Object scene, because that is the string
/// `findEntity(named:)` looks for.
struct Artefact: Identifiable, Hashable {
    let id = UUID()

    let title: String
    let author: String
    let level: String
    let year: Int
    let summary: String
    let modelName: String

    /// In the Exhibition scene both plinths hold the whole catalogue, so the
    /// entities there carry the side as well: "MyObject_A_Left".
    func entityName(on plinth: Plinth) -> String {
        return "\(modelName)_\(plinth.rawValue)"
    }
}

/// The catalogue. Both plinths choose from it. Replace these with your own --
/// and rename the entities in Reality Composer Pro to match, or the other way
/// round.
let artefacts = [
    Artefact(
        title: "Cone Study",
        author: "Alice Jones",
        level: "BA",
        year: 2026,
        summary: "A placeholder artefact. Swap the cone in MUIContent.rkassets for your own model.",
        modelName: "MyObject_A"
    ),
    Artefact(
        title: "Sphere Study",
        author: "Jon Doe",
        level: "BA",
        year: 2026,
        summary: "A placeholder artefact. Swap the sphere in MUIContent.rkassets for your own model.",
        modelName: "MyObject_B"
    ),
    Artefact(
        title: "Capsule Study",
        author: "Alice Jones & Jon Doe",
        level: "MA",
        year: 2026,
        summary: "A placeholder artefact. Swap the capsule in MUIContent.rkassets for your own model.",
        modelName: "MyObject_C"
    ),
    Artefact(
        title: "The Installation",
        author: "Jon Doe",
        level: "MA",
        year: 2026,
        summary: "Carry this into the artefact on the other plinth -- or the other way round -- and both react.",
        modelName: "Installation"
    )
]
