//
//  PodiumView.swift
//  MUI 26
//

import SwiftUI

struct PodiumView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        HStack {
            ForEach(podiums) { podium in
                Button {
                    appState.selectedPodium = podium
                } label: {
                    // The same string names the entity in Reality Composer Pro
                    // and the image set in Assets.xcassets.
                    Image(podium.modelName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(podium == appState.selectedPodium ? 0.33 : 1)
                        .padding()
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.roundedRectangle(radius: 36))
                .disabled(podium == appState.selectedPodium)
                .overlay {
                    if podium == appState.selectedPodium {
                        Text("Selected")
                    }
                }
            }
        }
        .padding()
        .frame(width: Constants.windowWidth, height: Constants.windowHeight)
        .glassBackgroundEffect()
    }
}

#Preview(windowStyle: .plain) {
    PodiumView()
        .environment(AppState())
}
