//
//  GameList.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameList<Content: View, Placeholder: View>: View {

	@EnvironmentObject private var library: LibraryModel

	@Binding private var selection: UUID?
	@State private var query = ""

	private let content: (Game) -> Content
	private let placeholder: Placeholder

	init(
		selection: Binding<UUID?>,
		@ViewBuilder content: @escaping (Game) -> Content,
		@ViewBuilder placeholder: () -> Placeholder
	) {
		_selection = selection
		self.content = content
		self.placeholder = placeholder()
	}

	init(
		selection: Binding<UUID?>,
		@ViewBuilder content: @escaping (Game) -> Content
	) where Placeholder == Text {
		self.init(selection: selection, content: content) {
			Text("We couldn't find any games")
		}
	}

	private var games: [Game] {
		var result = AnyRandomAccessCollection(library.games.lazy.filter { game in
			!game.isDeleted
		})
		if !query.isEmpty {
			result = AnyRandomAccessCollection(result.lazy.filter { game in
				game.name.localizedCaseInsensitiveContains(query)
			})
		}
		return result.sorted { lhs, rhs in
			lhs.name < rhs.name
		}
	}

	var body: some View {
		List(selection: $selection) {
			let games = self.games
			if games.isEmpty {
				placeholder
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				let steam = games.filter(\.isSteam)
				if !steam.isEmpty {
					Section("Steam") {
						ForEach(steam, content: GameLabel.init)
					}
				}
				let other = games.filter { !$0.isSteam }
				if !other.isEmpty {
					Section("Other") {
						ForEach(games, content: GameLabel.init)
					}
				}
			}
		}
		.searchable(text: $query, prompt: "Search your library")
	}

}
