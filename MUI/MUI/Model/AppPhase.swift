//
//  AppPhase.swift
//  MUI 26
//

import Foundation

/// Where the app currently is. An enum, because the app is in exactly one of
/// these at a time -- that is what an enum is for, and it makes the impossible
/// states (welcome *and* inspect at once) impossible to write down.
///
/// The three phases differ in what is on screen:
///
/// - `welcome`  nothing but this window
/// - `inspect`  this window, the podium window, the volume and the exhibition
/// - `review`   this window and the exhibition, with the editing scenes closed
enum AppPhase {
    case welcome
    case inspect
    case review

    var title: String {
        switch self {
            case .welcome: "Hello, Interaction Design"
            case .inspect: "IAD x Spatial Design"
            case .review: "Ready for Exhibition?"
        }
    }

    var headline: String {
        switch self {
            case .welcome: "26HS Mobile User Interface"
            case .inspect: "Windows, Volumes, Spaces"
            case .review: "Diploma Reveal"
        }
    }

    /// What the button on the welcome window reads, which is also what it does
    /// next: the phases run in this order and loop back round.
    var actionTitle: String {
        switch self {
            case .welcome: "Start"
            case .inspect: "Review"
            case .review: "Finish"
        }
    }

    /// The image at the top of the window. Reviewing swaps the course logo for
    /// the diploma mark.
    var imageName: String {
        switch self {
            case .welcome, .inspect: "Logo"
            case .review: "Diploma"
        }
    }

    /// The two images are not the same shape, so each phase brings the height
    /// and the breathing room that suit the one it shows. Keeping these here
    /// rather than in the view means the whole look of a phase is described in
    /// one place -- add a phase and the window follows without being touched.
    var imageHeight: CGFloat {
        switch self {
            case .welcome, .inspect: 60
            case .review: 80
        }
    }

    var imagePadding: CGFloat {
        switch self {
            case .welcome, .inspect: 28
            case .review: 24
        }
    }
}
