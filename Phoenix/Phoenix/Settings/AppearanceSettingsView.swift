//
//  AppearanceSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import AppKit

struct AppearanceSettingsView: View {
	@EnvironmentObject private var settings: PhoenixSettings

    var body: some View {
        Form {
			Toggle("Use system accent color", isOn: $settings.isAccentColorEnabled)
        }
    }

}
