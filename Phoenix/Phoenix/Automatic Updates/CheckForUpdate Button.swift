//
//  CheckForUpdate Command.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

/// Allows the user to manually check for updates
///
/// Requires the ``UpdaterModel`` to be present in the environment.
struct CheckForUpdateButton: View {
	@EnvironmentObject private var updater: UpdaterModel

	var body: some View {
		Button("Check for Updates", action: updater.checkForUpdates)
			.disabled(!updater.canCheckForUpdates)
	}
}
