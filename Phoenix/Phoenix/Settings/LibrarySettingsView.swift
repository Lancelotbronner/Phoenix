//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct LibrarySettingsView: View {
	@EnvironmentObject private var steam: SteamModel
	@EnvironmentObject private var library: LibraryModel

    var body: some View {
        Form {
			Section("Steam") {
				Toggle("Automatic import", isOn: $steam.isAutomaticImportEnabled)
				IntervalPicker("Import check interval", selection: $steam.importCheckInterval)
				LabeledContent("Last Import") {
					if let date = steam.lastImportDate {
						Text(date.formatted(date: .long, time: .shortened))
					} else {
						Text("Never")
					}
				}
				ImportFromSteamButton()
				Button("Clear Steam library") {
					library.games.removeAll(where: \.isSteam)
				}
			}
		}
    }
}
