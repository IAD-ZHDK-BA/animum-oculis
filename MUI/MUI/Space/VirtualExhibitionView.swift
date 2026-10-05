//
//  VirtualExhibitionView.swift
//  MUI 26
//

import SwiftUI
import RealityKit
import MUIContent

struct VirtualExhibitionView: View {
    @Environment(AppState.self) var appState

    // An entity you found in the scene can be kept in a state variable and
    // used again later, from anywhere in this view -- no second
    // findEntity(named:) call, and no passing it around as an argument.
    //
    // The scene has not loaded yet when the view is first made, so these start
    // out empty and fill in inside the `make` closure below. This is the
    // pattern to reach for as your own interactions grow.
    @State private var podiumEntities: [Plinth: Entity] = [:]
    @State private var sparksEntities: [Plinth: Entity] = [:]

    /// Where each carryable object stands when nobody is holding it, noted down
    /// once at the start so we can put it back there afterwards.
    @State private var homeTransforms: [String: Transform] = [:]

    var body: some View {
        RealityView { content in
            // `make` runs once, like setup() in p5.js. Everything that only
            // has to happen a single time belongs here.
            guard let exhibitionScene = try? await Entity(named: Constants.exhibitionSceneName, in: muiContentBundle) else {
                return
            }
            content.add(exhibitionScene)
            showSelectedEntities(in: exhibitionScene)

            for plinth in Plinth.allCases {
                // --- The reveal, once per plinth --------------------------
                // The gesture does not say what the tap does.
                // applyTapForBehaviors hands it to the Behaviors component on
                // that podium, and the Reality Composer Pro scene decides: play
                // *that* plinth's reveal timeline. Tapping the left podium
                // leaves the right one standing.
                //
                // Taps only count while reviewing. The podium's input target is
                // switched off in the other phases, so this guard should never
                // be the thing that stops one -- it is here to say the rule out
                // loud, next to the action it governs.
                if let podium = exhibitionScene.findEntity(named: plinth.podiumName) {
                    podiumEntities[plinth] = podium

                    podium.components.set(GestureComponent(
                        TapGesture().onEnded {
                            guard appState.phase == .review else { return }
                            _ = podiumEntities[plinth]?.applyTapForBehaviors()
                        }
                    ))
                }

                sparksEntities[plinth] = exhibitionScene.findEntity(named: plinth.sparksName)

                // --- Carrying things around -------------------------------
                // configureEntity makes an entity draggable, and on the way
                // also gives it a Collision and an Input Target component. Both
                // are needed before anything can collide, so the subscriptions
                // below depend on this loop having run.
                //
                // .stay means RealityKit leaves a released object wherever you
                // let go of it. We note down where each one belongs and animate
                // it back there ourselves, which is what lets us pick the
                // easing -- the built-in return is a spring, and springs
                // overshoot.
                for artefact in artefacts {
                    let name = artefact.entityName(on: plinth)
                    guard let entity = exhibitionScene.findEntity(named: name) else { continue }

                    ManipulationComponent.configureEntity(entity)
                    entity.components[ManipulationComponent.self]?.releaseBehavior = .stay
                    homeTransforms[name] = entity.transform

                    // Two entities can only collide if both carry a Collision
                    // component, which they all just got. Carry one plinth's
                    // object into the other's and both sets of sparks start.
                    _ = content.subscribe(to: CollisionEvents.Began.self, on: entity) { event in
                        setSparks(true)
                        print("\(event.entityA.name) touched \(event.entityB.name)")
                    }

                    _ = content.subscribe(to: CollisionEvents.Ended.self, on: entity) { _ in
                        setSparks(false)
                    }
                }
            }

            // Picking something up sinks the podium it came from and fades that
            // plinth's label. The other plinth is left alone.
            _ = content.subscribe(to: ManipulationEvents.WillBegin.self, on: exhibitionScene) { event in
                guard let plinth = plinth(holding: event.entity) else {
                    return
                }
                setPodiumHeight(Constants.podiumDip, on: plinth)
                withAnimation(.smooth) {
                    appState.heldPlinth = plinth
                }
            }

            // WillEnd is the last event of a manipulation, so this is the point
            // at which the object is ours to move again.
            _ = content.subscribe(to: ManipulationEvents.WillEnd.self, on: exhibitionScene) { event in
                if let home = homeTransforms[event.entity.name] {
                    event.entity.move(
                        to: home,
                        relativeTo: event.entity.parent,
                        duration: Constants.returnDuration,
                        timingFunction: .easeOut
                    )
                }

                // Read the plinth back from state rather than from the event:
                // by now the object is no longer where it started.
                guard let plinth = appState.heldPlinth else {
                    return
                }
                setPodiumHeight(.zero, on: plinth)
                withAnimation(.smooth) {
                    appState.heldPlinth = nil
                }
            }

        } update: { content in
            // `update` runs again every time something it reads from appState
            // changes -- which is exactly why the labels live here and the
            // one-time wiring above does not.
            guard let exhibitionScene = content.entities.first else {
                return
            }
            showSelectedEntities(in: exhibitionScene)

            // A podium only answers to taps while reviewing. Switching its
            // input target off in the other phases takes the highlight away
            // too, so it does not look tappable when it is not.
            for podium in podiumEntities.values {
                podium.components[InputTargetComponent.self]?.isEnabled = appState.phase == .review
            }

            // Each plinth gets the same label view, filled with its own
            // artefact. An attachment has no position of its own, it inherits
            // its parent's -- here, the empty UI_Anchor entity beside it.
            for plinth in Plinth.allCases {
                guard let uiAnchor = exhibitionScene.findEntity(named: plinth.uiAnchorName) else {
                    continue
                }

                uiAnchor.components.set(ViewAttachmentComponent(
                    rootView: ExhibitionLabelView(artefact: artefact(on: plinth))
                        .opacity(appState.heldPlinth == plinth ? 0 : 1)
                ))
                // And it turns to face whoever is looking at it.
                uiAnchor.components.set(BillboardComponent())
            }
        }
        // Arriving in the review phase plays both reveals once, unprompted.
        // From then on it is the taps that replay them -- and only for as long
        // as we stay in this phase.
        .onChange(of: appState.phase) { _, phase in
            guard phase == .review else { return }
            playReveals()
        }
    }

    /// Plays each plinth's reveal timeline, the same way a tap on it would.
    func playReveals() {
        for podium in podiumEntities.values {
            _ = podium.applyTapForBehaviors()
        }
    }

    /// What stands on a given plinth right now.
    func artefact(on plinth: Plinth) -> Artefact {
        appState.selectedArtefacts[plinth] ?? artefacts[0]
    }

    /// On each plinth, exactly one artefact and exactly one podium shape are
    /// enabled -- the selected ones. Everything else is switched off rather
    /// than removed, so switching back is free.
    func showSelectedEntities(in scene: Entity) {
        for plinth in Plinth.allCases {
            for artefact in artefacts {
                scene.findEntity(named: artefact.entityName(on: plinth))?.isEnabled =
                    artefact == appState.selectedArtefacts[plinth]
            }

            for podium in podiums {
                scene.findEntity(named: podium.entityName(on: plinth))?.isEnabled =
                    podium == appState.selectedPodiums[plinth]
            }
        }
    }

    /// Which plinth a carried object came from.
    ///
    /// Everything on a plinth sits somewhere below its `Plinth_…` entity, so
    /// following `parent` upwards from whatever was grabbed always lands on the
    /// right one. This keeps working however deeply you nest your own objects.
    func plinth(holding entity: Entity) -> Plinth? {
        var current: Entity? = entity

        while let candidate = current {
            if let match = Plinth.allCases.first(where: { $0.containerName == candidate.name }) {
                return match
            }
            current = candidate.parent
        }

        return nil
    }

    /// Moves one plinth's podium up or down, smoothly. Uses the entities we
    /// stored in `make` instead of looking them up again.
    func setPodiumHeight(_ value: Float, on plinth: Plinth) {
        Entity.animate(.smooth) {
            podiumEntities[plinth]?.position.y = value
        }
    }

    /// Both emitters at once: a collision always involves both plinths.
    func setSparks(_ isEmitting: Bool) {
        for sparks in sparksEntities.values {
            sparks.components[ParticleEmitterComponent.self]?.isEmitting = isEmitting
        }
        appState.isInstallationActive = isEmitting
    }
}

#Preview(immersionStyle: .mixed) {
    VirtualExhibitionView()
        .environment(AppState())
}
