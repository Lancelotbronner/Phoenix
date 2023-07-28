//
//  Updater.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI
import Sparkle

/// View model which wraps over Sparkle's update framework.
final class UpdaterModel: ObservableObject {

	@Published private(set) var canCheckForUpdates = false

	@Published private(set) var lastUpdateCheckDate: Date?

	@Published var automaticallyChecksForUpdates = false {
		didSet { updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates }
	}

	@Published var automaticallyDownloadsUpdates = false {
		didSet { updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates }
	}

	@Published var updateCheckInterval = 0.0 {
		didSet { updater.updateCheckInterval = updateCheckInterval }
	}

	private let updater: SPUUpdater

	init(using updater: SPUUpdater) {
		self.updater = updater

		updater
			.publisher(for: \.canCheckForUpdates)
			.assign(to: &$canCheckForUpdates)

		updater
			.publisher(for: \.lastUpdateCheckDate)
			.assign(to: &$lastUpdateCheckDate)

		updater
			.publisher(for: \.automaticallyChecksForUpdates)
			.assign(to: &$automaticallyChecksForUpdates)

		updater
			.publisher(for: \.automaticallyDownloadsUpdates)
			.assign(to: &$automaticallyDownloadsUpdates)

		updater
			.publisher(for: \.updateCheckInterval)
			.assign(to: &$updateCheckInterval)
	}

	convenience init() {
		let controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
		self.init(using: controller.updater)
	}

	func checkForUpdates() {
		updater.checkForUpdates()
	}

}
