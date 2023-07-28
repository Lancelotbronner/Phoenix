//
//  GamesModel.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

final class LibraryModel: ObservableObject {

	@Published private var library = Library()

	let directory: URL

	init() {
		guard let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			logger.write("[ERROR]: Could not create the Application Support directory")
			fatalError("Could not locate the Application Support directory")
		}
		directory = applicationSupport.appending(component: "Phoenix", directoryHint: .isDirectory)

		if !FileManager.default.fileExists(atPath: directory.path(percentEncoded: false)) {
			do {
				try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
			} catch {
				logger.write("[ERROR]: Could not create the Phoenix directory: \(error)")
				fatalError("Could not create the Phoenix directory")
			}
		}

		reload()
	}

	func reload() {
		let url = directory.appending(component: "games.json", directoryHint: .notDirectory)
		guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else {
			return
		}

		do {
			let data = try Data(contentsOf: url)
			library = try JSONDecoder().decode(Library.self, from: data)
		} catch {
			logger.write("[ERROR]: Could not load library: \(error)")
		}
	}

	func persist() {
		let url = directory.appending(component: "games.json", directoryHint: .notDirectory)

		do {
			let data = try JSONEncoder().encode(library)
			try data.write(to: url, options: .atomic)
		} catch {
			logger.write("[ERROR]: Could not write library: \(error)")
		}
	}

	//MARK: - Game Management

	var games: [Game] {
		_read { yield library.games }
		_modify { yield &library.games }
	}

	func indexOf(game id: UUID) -> Int? {
		games.firstIndex { $0.id == id }
	}

	func bindingOf(game id: UUID) -> Binding<Game>? {
		guard let i = indexOf(game: id) else { return nil }
		let tmp = Binding<Game?> {
			self.games.indices.contains(i) ? self.games[i] : nil
		} set: {
			if let newValue = $0, self.games.indices.contains(i) {
				self.games[i] = newValue
			}
		}
		return Binding(tmp)
	}

	func modify(_ id: UUID, with transform: (inout Game) -> Void) {
		guard let i = indexOf(game: id) else { return }
		transform(&games[i])
	}

	func steamGames(filter search: String) -> AnyRandomAccessCollection<Game> {
		var results = AnyRandomAccessCollection(library.games.lazy
			.filter(\.isSteam)
			.sorted { $0.name < $1.name })
		
		if !search.isEmpty {
			results = AnyRandomAccessCollection(results.lazy.filter {
				search.contains($0.name)
			})
		}
		return results
	}

	func otherGames(filter search: String) -> AnyRandomAccessCollection<Game> {
		var results = AnyRandomAccessCollection(library.games.lazy
			.filter { !$0.isSteam }
			.sorted { $0.name < $1.name })

		if !search.isEmpty {
			results = AnyRandomAccessCollection(results.lazy.filter {
				search.contains($0.name)
			})
		}
		return results
	}

}
