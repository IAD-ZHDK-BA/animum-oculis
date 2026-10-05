//
//  OnboardingView.swift
//  MUI 26
//

import SwiftUI

struct OnboardingView: View {
    // The system hands these four actions down through the environment. They
    // are what opens and closes the other three scenes.
    @Environment(\.openWindow) var showWindow
    @Environment(\.openImmersiveSpace) var showSpace

    @Environment(\.dismissWindow) var closeWindow
    @Environment(\.dismissImmersiveSpace) var closeSpace

    @Environment(AppState.self) var appState

    var body: some View {
        // @Bindable gives the switcher a two-way binding into appState.
        @Bindable var state = appState

        VStack {
            Image(appState.phase.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: appState.phase.imageHeight)
                .frame(maxWidth: .infinity)
                .blendMode(.multiply)
                .padding(.vertical, appState.phase.imagePadding)
                .background(.regularMaterial)

            Text(appState.phase.title)
                .font(.extraLargeTitle2)
                .padding(.top)

            Text(appState.phase.headline)
                .foregroundStyle(.secondary)
                .padding(.bottom)

            Spacer()

            // One button, walking the three phases in order and looping back.
            // What it says and what it does both come from the current phase.
            Button(appState.phase.actionTitle) {
                switch appState.phase {
                    case .welcome:
                        showWindow(id: Constants.podiumWindowIdentifier)
                        showWindow(id: Constants.objectVolumeIdentifier)
                        Task {
                            // Opening a space is asynchronous -- it has to be
                            // awaited, which is why it sits inside a Task.
                            await showSpace(id: Constants.exhibitionSpaceIdentifier)
                            withAnimation {
                                appState.phase = .inspect
                            }
                        }

                    case .inspect:
                        // The exhibition stays open. Only the two scenes you
                        // edit with close, so nothing stands between you and it.
                        closeWindow(id: Constants.podiumWindowIdentifier)
                        closeWindow(id: Constants.objectVolumeIdentifier)
                        withAnimation {
                            appState.phase = .review
                        }

                    case .review:
                        Task {
                            await closeSpace()
                            withAnimation {
                                appState.phase = .welcome
                            }
                        }
                }
            }
            .padding(.bottom)
        }
        .frame(width: Constants.windowWidth, height: Constants.windowHeight)
        .glassBackgroundEffect()
        // Which plinth everything else is aimed at. The podium window and the
        // volume's picker both write to whichever side is chosen here, so one
        // set of controls furnishes either plinth.
        .ornament(attachmentAnchor: .scene(.bottom)) {
            if appState.phase == .inspect {
                Picker("Plinth", selection: $state.editingPlinth) {
                    ForEach(Plinth.allCases) { plinth in
                        Text(plinth.title)
                            .tag(plinth)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
                .padding(.top)
                .glassBackgroundEffect()
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    OnboardingView()
        .environment(AppState())
}
