//
//  Sidebar.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct Sidebar: View {

	@EnvironmentObject private var library: LibraryModel
	@EnvironmentObject private var navigation: NavigationModel

	var body: some View {
		GameList(selection: $navigation.game, content: GameLabel.init) {
			VStack {
				Image(systemName: "magnifyingglass")
					.font(.largeTitle)
				Text("You don't have any games")
					.font(.caption)
					.lineLimit(nil)
					.multilineTextAlignment(.center)
			}
			.foregroundStyle(.secondary)
		}
		.contextMenu(forSelectionType: UUID.self) { ids in
			if !ids.isEmpty {
				Button("Delete") {
					for id in ids {
						library.modify(id) { game in
							game.isDeleted = true
						}
					}
					library.persist()
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				AddGameButton()
			}
		}
	}

}
