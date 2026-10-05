//
//  VirtualObjectView.swift
//  MUI 26
//

import SwiftUI
import RealityKit
import MUIContent

struct VirtualObjectView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        // @Bindable gives the Picker a two-way binding into appState, so
        // choosing an artefact here writes straight back to the shared state
        // and the immersive space follows along.
        @Bindable var state = appState

        GeometryReader3D { proxy in
            RealityView { content in
                guard let objectScene = try? await Entity(named: Constants.objectSceneName, in: muiContentBundle) else {
                    return
                }
                adjustEntityToVolumeSize(content, geometry: proxy, entity: objectScene)
                showSelectedArtefact(in: objectScene)
                content.add(objectScene)
            } update: { content in
                guard let objectScene = content.entities.first else {
                    return
                }
                adjustEntityToVolumeSize(content, geometry: proxy, entity: objectScene)
                showSelectedArtefact(in: objectScene)
            }
        }
        .ornament(attachmentAnchor: .scene(.bottomFront)) {
            Picker("Artefact", selection: $state.selectedArtefact) {
                ForEach(artefacts) { artefact in
                    Text(artefact.title)
                        .tag(artefact)
                }
            }
            .pickerStyle(.segmented)
            .glassBackgroundEffect()
        }
    }

    /// Exactly one artefact is enabled -- the selected one. Everything else in
    /// the scene is switched off rather than removed, so switching back is free.
    func showSelectedArtefact(in scene: Entity) {
        for artefact in artefacts {
            scene.findEntity(named: artefact.modelName)?.isEnabled = artefact == appState.selectedArtefact
        }
    }

    /// Scales and lifts the model so it sits on the floor of the volume and
    /// fills a sensible fraction of it, whatever size the model happens to be.
    func adjustEntityToVolumeSize(_ content: RealityViewContent, geometry proxy: GeometryProxy3D, entity model: Entity, percentage: Float = 0.25) {
        let viewBounds = content.convert(proxy.frame(in: .local), from: .local, to: .scene)

        // Set the model's position to the bottom of the visual bounding box.
        model.position.y -= model.visualBounds(relativeTo: nil).min.y

        // Adjust the model's position on the y-axis to align with the view bounds.
        model.position.y += viewBounds.min.y

        /// The base size of the model when the scale is 1.
        let baseExtents = model.visualBounds(relativeTo: nil).extents / model.scale

        /// The scale required for the model to fit the bounds of the volumetric window.
        let scale = Float(viewBounds.extents.x) / baseExtents.x

        // Apply the scale to the model to fill the percentage of the window's full size.
        model.scale = SIMD3<Float>(repeating: scale * percentage)
    }
}

#Preview(windowStyle: .volumetric) {
    VirtualObjectView()
        .environment(AppState())
}
