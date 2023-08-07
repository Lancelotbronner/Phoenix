//
//  SteamModel.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-17.
//

import SwiftUI
import OSLog

final class SteamModel: ObservableObject {

	@AppStorage("steam.import.enabled")
	var isAutomaticImportEnabled = false

	@AppStorage("steam.import.checkInterval")
	var importCheckInterval: TimeInterval = 86_400

	@AppStorage("steam.import.lastDate")
	private(set) var lastImportDate: Date?

	static let logger = PhoenixApp.logger(category: "Steam")

	var logger: Logger {
		_read { yield SteamModel.logger }
	}

	lazy var steamURL: URL = {
		URL.homeDirectory.appending(components: "Library", "Application Support", "Steam", directoryHint: .isDirectory)
	}()

	func checkForImport() -> Bool {
		guard
			isAutomaticImportEnabled,
			lastImportDate.flatMap({ $0.timeIntervalSinceNow < -importCheckInterval }) ?? true
		else { return false }
		return true
	}

	func importGames(using library: LibraryModel) async {
		logger.notice("Importing Steam library")
		await SandboxManager.shared.access(steamURL) { [self] steamURL in
			let steamappsURL = steamURL.appending(component: "steamapps", directoryHint: .isDirectory)
			guard FileManager.default.fileExists(atPath: steamappsURL.path(percentEncoded: false)) else { return }

			let steamapps: [URL]
			do {
				steamapps = try FileManager.default.contentsOfDirectory(at: steamappsURL, includingPropertiesForKeys: nil)
			} catch {
				logger.error("Could not read contents of Steam directory: \(error)")
				return
			}

			for fileURL in steamapps {
				guard fileURL.lastPathComponent.hasSuffix(".acf") else { continue }

				let manifest: SteamAppManifest
				do {
					manifest = try SteamAppManifest(contentsOf: fileURL)
				} catch {
					logger.error("Failed to parse game manifest at \(fileURL)")
					continue
				}

				guard let appid = manifest["appid"].flatMap(Int.init) else {
					logger.error("Game manifest is missing appid")
					continue
				}

				if let i = library.games.firstIndex(where: { $0.steam?.appid == appid }) {
					logger.info("Game \(appid.description) '\(manifest["name"] ?? "")' already exists with id '\(library.games[i].id)', skipping.")
					continue
				}

				let game = await self.extract(appid, using: manifest)
				logger.notice("Adding game \(appid.description) '\(game.name)' to library.")
				await MainActor.run {
					library.games.append(game)
				}

				// Ensure we don't get rate-limited by Steam
				try? await Task.sleep(for: .seconds(2))
			}

			await MainActor.run {
				library.persist()
				self.lastImportDate = .now
			}
		}
	}

	func extract(_ appid: Int, using manifest: SteamAppManifest) async -> Game {
		var game = Game(
			profiles: [
				Profile(name: "Steam", command: "open steam://run/\(appid)")
			],
			name: manifest["name"] ?? "Unknown Steam Game",
			steam: SteamMetadata(appid: appid),
			isDeleted: false)

		logger.debug("Processing application \(appid.description) '\(game.name)'...")
		async let details = fetch(detailsOf: appid)

		let libraryCacheURL = steamURL.appending(components: "appcache", "librarycache", directoryHint: .isDirectory)

		let iconURL = libraryCacheURL.appending(component: "\(appid)_icon.jpg", directoryHint: .notDirectory)
		if FileManager.default.fileExists(atPath: iconURL.path(percentEncoded: false)) {
			game.icon = iconURL
		}

		let libraryURL = libraryCacheURL.appending(component: "\(appid)_library_600x900.jpg", directoryHint: .notDirectory)
		if FileManager.default.fileExists(atPath: libraryURL.path(percentEncoded: false)) {
			game.library = libraryURL
		}

		let bannerURL = libraryCacheURL.appending(component: "\(appid)_library_hero.jpg", directoryHint: .notDirectory)
		if FileManager.default.fileExists(atPath: bannerURL.path(percentEncoded: false)) {
			game.banner = bannerURL
		}

		let headerURL = libraryCacheURL.appending(component: "\(appid)_header.jpg", directoryHint: .notDirectory)
		if FileManager.default.fileExists(atPath: headerURL.path(percentEncoded: false)) {
			game.header = headerURL
		}

		if let details = await details {
			if let value = details.categories {
				game.feature = value.lazy
					.map(\.description)
					.joined(separator: ",")
			}

			if let value = details.genres {
				game.genre = value.lazy
					.map(\.description)
					.joined(separator: ",")
			}

			game.summary = try? AttributedString(html: details.short_description)
			game.details = try? AttributedString(html: details.detailed_description)
			game.developer = details.developers?.joined(separator: ",")
			game.publisher = details.publishers?.joined(separator: ",")
			game.releaseDate = Date(rawValue: details.release_date.date)
		}

		return game
	}

	func fetch(detailsOf appid: Int) async -> ApplicationInfo? {
		var result: ApplicationDetailsResponse?
		do {
			result = try await SteampoweredClient.shared.details(of: appid)
		} catch {
			logger.error("Failed to retrieve details of \(appid.description): \(error)")
			print(error.localizedDescription)
		}

		guard let result, result.success else { return nil }
		return result.data
	}

}
