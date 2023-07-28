//
//  ContentView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-21.
//

import SwiftUI

struct ContentView: View {

	@EnvironmentObject private var navigation: NavigationModel
	@EnvironmentObject private var library: LibraryModel
	@Environment(\.openWindow) private var openWindow

	var body: some View {
		NavigationSplitView {
			Sidebar()
		} detail: {
			if let id = navigation.game, let $game = library.bindingOf(game: id) {
				NavigationStack(path: $navigation.path) {
					GameProfileView($game)
				}
			} else if library.games.isEmpty {
				VStack {
					Image(systemName: "gamecontroller")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: 120, maxHeight: 120)
						.foregroundStyle(.secondary)
					Text("You can import games from Steam in the preferences or add them yourself.")
						.lineLimit(nil)
						.multilineTextAlignment(.center)
						.foregroundStyle(.secondary)
					AddGameButton {
						Label("Add a Game", systemImage: "plus")
					}
				}
				.buttonStyle(.link)
				.background(RoundedRectangle(cornerRadius: 10)
					.fill(Material.thick))
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.navigationTitle("Phoenix")
			} else {
				VStack {
					Image(systemName: "gamecontroller")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(maxWidth: 120, maxHeight: 120)
						.foregroundStyle(.secondary)
					Text("Select a game from the left.")
						.lineLimit(nil)
						.multilineTextAlignment(.center)
						.foregroundStyle(.secondary)
				}
				.background(RoundedRectangle(cornerRadius: 10)
					.fill(Material.thick))
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.navigationTitle("Phoenix")
			}
		}
	}

}
