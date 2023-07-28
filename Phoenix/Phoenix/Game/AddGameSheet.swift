//
//  AddGameSheet.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct AddGameSheet: View {

	@EnvironmentObject private var library: LibraryModel
	@EnvironmentObject private var navigation: NavigationModel
	@Environment(\.dismiss) private var dismiss

	@State private var game = Game()

	var body: some View {
		GameEditor($game)
			.toolbar {
				Button("Cancel", role: .cancel) {
					dismiss()
				}
				.keyboardShortcut(.cancelAction)
				Button("Add to Library") {
					library.games.append(game)
					library.persist()
					navigation.game = game.id
					dismiss()
				}
				.keyboardShortcut(.defaultAction)
				.disabled(game.isInvalid)
			}
	}
}
