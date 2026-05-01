//
//  LaunchSplashView.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftUI

struct LaunchSplashView: View {
    let duration: TimeInterval

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var progress = 0.0

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(
                x: proxy.size.width / 2,
                y: proxy.size.height / 2
            )

            ZStack {
                LBColor.background
                    .ignoresSafeArea()

                Image("SplashIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144, height: 144)
                    .position(x: center.x, y: center.y)
                    .accessibilityHidden(true)

                progressBar
                    .frame(width: 156, height: 4)
                    .position(x: center.x, y: center.y + 102)
                    .opacity(reduceMotion ? 1 : progress)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("LiftBook is opening")
        .onAppear(perform: startProgress)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LBColor.text.opacity(0.12))

                Capsule()
                    .fill(.tint)
                    .frame(width: proxy.size.width * progress)
            }
        }
    }

    @MainActor
    private func startProgress() {
        guard progress == 0 else {
            return
        }

        if reduceMotion {
            progress = 1
        } else {
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}

#Preview {
    LaunchSplashView(duration: 2)
}
