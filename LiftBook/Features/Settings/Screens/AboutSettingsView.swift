//
//  AboutSettingsView.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        List {
            Section("App") {
                LabeledContent("App", value: appName)
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
                LabeledContent("Bundle", value: bundleIdentifier)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "LiftBook"
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? "1"
    }

    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unavailable"
    }
}

#Preview {
    NavigationStack {
        AboutSettingsView()
    }
}
