//
//  SettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        TabView {
            LibrarySettingsView()
				.padding()
                .tabItem { Label("Library", systemImage: "books.vertical") }
			HiddenGamesSettingsView()
				.padding()
				.tabItem { Label("Deleted Games", systemImage: "eye.slash.fill") }
            AppearanceSettingsView()
				.padding()
                .tabItem { Label("Appearance", systemImage: "paintpalette") }
			AutomaticUpdateSettingsView()
				.padding()
				.tabItem { Label("Updates", systemImage: "arrow.triangle.2.circlepath.circle") }
		}
		.frame(minWidth: 450, minHeight: 240, alignment: .topLeading)
		.formStyle(.grouped)
    }
}
