//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI
import OSLog

@main struct PhoenixApp: App {

	static let logger = logger(category: "Application")

	static func logger(category: String) -> Logger {
		Logger(subsystem: Bundle.main.bundleIdentifier!, category: category)
	}

	private let updater = UpdaterModel()
	private let library = LibraryModel()
	private let steam = SteamModel()
	private let images: ImageCacheModel
	private let navigation = NavigationModel()

	init() {
		images = ImageCacheModel(at: library.directory
			.appending(component: "images", directoryHint: .isDirectory))
	}

	private func onAppear() {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? " Unknown"
		PhoenixApp.logger.notice("Phoenix v\(version) launched at \(Date.now.formatted(date: .long, time: .shortened)) on macOS \(ProcessInfo.processInfo.operatingSystemVersionString)")
	}

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(PhoenixSettings.shared)
				.environmentObject(library)
				.environmentObject(steam)
				.environmentObject(images)
				.environmentObject(navigation)
                .frame(minWidth: 1024, idealWidth: 1980, minHeight: 768, idealHeight: 1080)
				.onAppear {
					onAppear()
					if steam.checkForImport() {
						Task {
							await steam.importGames(using: library)
						}
					}
				}
        }
		.commands {
            CommandGroup(after: CommandGroupPlacement.help) {
				Divider()
				Menu("Developer Tools") {
					Button("Open Application Support") {
						print(library.directory)
						NSWorkspace.shared.open(library.directory)
						PhoenixApp.logger.info("Opened 'Application Support/Phoenix'")
					}
					Button("Open Steam Cache") {
						let url = URL(filePath: "/Users/lancelot/Library/Application Support/Steam")
						_ = SandboxManager.shared.access(url) { url in
							NSWorkspace.shared.open(library.directory)
						}
						PhoenixApp.logger.info("Opened 'Application Support/Steam'")
					}
				}
            }
            CommandGroup(after: .appInfo) {
                CheckForUpdateButton()
					.environmentObject(updater)
            }
        }

        Settings {
            SettingsView()
				.environmentObject(PhoenixSettings.shared)
				.environmentObject(library)
				.environmentObject(steam)
				.environmentObject(images)
				.environmentObject(updater)
        }
    }
}
