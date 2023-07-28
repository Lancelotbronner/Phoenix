//
//  HiddenGamesSettingsView.swift
//  Phoenix
//
//  Created by james hughes on 6/18/23.
//

import SwiftUI

struct HiddenGamesSettingsView: View {

	@EnvironmentObject private var library: LibraryModel
	@EnvironmentObject private var navigation: NavigationModel

	@State private var selection: UUID?

	var body: some View {
		Form {
			let games = library.games.lazy
				.filter { $0.isDeleted }
				.sorted { lhs, rhs in lhs.name < rhs.name }
			List(selection: $selection) {
				ForEach(games, content: GameLabel.init)
				if games.isEmpty {
					Text("You don't have any hidden games")
				}
			}
			.contextMenu(forSelectionType: UUID.self) { ids in
				if !ids.isEmpty {
					Button("Restore") {
						for id in ids {
							library.modify(id) { game in
								game.isDeleted = false
							}
						}
						library.persist()
					}
				}
			}
		}
	}

}
