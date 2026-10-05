//
//  ExhibitionLabelView.swift
//  MUI 26
//

import SwiftUI

/// An ordinary SwiftUI view. It becomes part of the 3D scene in
/// `VirtualExhibitionView`, where it is wrapped in a `ViewAttachmentComponent`
/// and hung on the `UI_Anchor` entity.
struct ExhibitionLabelView: View {
    let artefact: Artefact

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "info")
                .imageScale(.large)
                .padding(.leading, 22)
                .padding(.top, 18)

            VStack(alignment: .leading) {
                Text(artefact.title)
                    .bold()
                Text(artefact.author)
                Text("\(artefact.level), \(String(artefact.year))")
                    .padding(.bottom)
                Text(artefact.summary)
            }
            .padding(22)
        }
        .frame(width: 320, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            if let url = URL(string: "https://interactiondesign.zhdk.ch/en/projects/") {
                Link(destination: url) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                .padding(22)
            }
        }
        .glassBackgroundEffect(in: .rect(cornerRadius: Constants.hoverEffectSize / 2))
        // Collapsed to a small rounded badge until you look at it, then it
        // animates out to full size. Hover effects run on the device itself,
        // so nothing about where you are looking reaches the app.
        .hoverEffect { effect, isActive, proxy in
            effect
                .animation(.smooth.delay(isActive ? 0.5 : 0.2), body: { content in
                    content
                        .clipShape(.rect(cornerRadius: Constants.hoverEffectSize / 2).size(
                            width: isActive ? proxy.size.width : Constants.hoverEffectSize,
                            height: isActive ? proxy.size.height : Constants.hoverEffectSize,
                            anchor: .topLeading
                        ))
                        .scaleEffect(isActive ? 1.05 : 1.0)
                })
        }
    }
}

#Preview {
    ExhibitionLabelView(artefact: artefacts[0])
}
