//
//  PhoenixApp.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

@main struct PhoenixApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	private let updater = UpdaterModel()
	private let library = LibraryModel()
	private let steam = SteamModel()
	private let images: ImageCacheModel
	private let navigation = NavigationModel()

	init() {
		images = ImageCacheModel(at: library.directory
			.appending(component: "images", directoryHint: .isDirectory))
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
						logger.write("[INFO]: Opened 'Application Support/Phoenix'")
					}
					Button("Open Steam Cache") {
						let url = URL(filePath: "/Users/lancelot/Library/Application Support/Steam")
						_ = SandboxManager.shared.access(url) { url in
							NSWorkspace.shared.open(library.directory)
						}
						logger.write("[INFO]: Opened 'Application Support/Steam'")
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

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationWillFinishLaunching(_ notification: Notification) {
		NSSetUncaughtExceptionHandler { exception in
			// Log the stack trace to the console
			print("Uncaught exception: \(exception)")
			print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
		}
		let processInfo = ProcessInfo.processInfo
		let operatingSystemVersion = processInfo.operatingSystemVersionString
		let hostName = processInfo.hostName
		let device = Host.current().localizedName!
		let userName = NSUserName()
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .long
		let dateString = dateFormatter.string(from: Date())
		let timeZone = TimeZone.current.identifier
		let numCores = ProcessInfo.processInfo.activeProcessorCount
		let memSize = ProcessInfo.processInfo.physicalMemory
		let appVersion =
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		logger.write("[OS]: Operating system version: \(operatingSystemVersion)")
		logger.write("[OS]: Host name: \(hostName)")
		logger.write("[OS]: Device: \(device)")
		logger.write("[OS]: User name: \(userName)")
		logger.write("[OS]: Date and time: \(dateString)")
		logger.write("[OS]: Time zone: \(timeZone)")
		logger.write("[OS]: Number of cores: \(numCores)")
		logger.write("[OS]: Total RAM available: \(memSize) bytes")
		logger.write("[OS]: App version: \(appVersion)")
		logger.write("[INFO]: Phoenix App Launched.")
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		NSSetUncaughtExceptionHandler { exception in
			// Log the stack trace to the console
			print("Uncaught exception: \(exception)")
			print("Stack trace: \(exception.callStackSymbols.joined(separator: "\n"))")
		}
		logger.write("[INFO]: Phoenix App finished launching.")
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// This method is called when the application is about to terminate. Save data if appropriate.
		logger.write("[INFO]: Phoenix App shutting down.")
	}
}
