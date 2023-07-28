//
//  EditGameSheet.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct EditGameSheet: View {

	@EnvironmentObject private var library: LibraryModel
	@Environment(\.dismiss) private var dismiss
	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		GameEditor($game)
			.toolbar {
				Button("Save Changes") {
					library.persist()
					dismiss()
				}
				.keyboardShortcut(.cancelAction)
				.disabled(game.isInvalid)
			}
	}
}
