//
//  AutomaticUpdateViews.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct AutomaticUpdateSettingsView: View {
	@EnvironmentObject private var updater: UpdaterModel

	var body: some View {
		Form {
			Toggle("Automatically check for updates", isOn: $updater.automaticallyChecksForUpdates)

			Toggle("Automatically download updates", isOn: $updater.automaticallyDownloadsUpdates)
				.disabled(!updater.automaticallyChecksForUpdates)

			IntervalPicker("Update check interval", selection: $updater.updateCheckInterval)
				.disabled(!updater.automaticallyChecksForUpdates)

			Divider()
				.foregroundStyle(.clear)

			CheckForUpdateButton()

			(Text("Last checked: ") + formattedLastUpdateCheckDate)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
	}

	var formattedLastUpdateCheckDate: Text {
		if let date = updater.lastUpdateCheckDate {
			return Text(verbatim: date.formatted(date: .complete, time: .shortened))
		} else {
			return Text("Never")
		}
	}

}
