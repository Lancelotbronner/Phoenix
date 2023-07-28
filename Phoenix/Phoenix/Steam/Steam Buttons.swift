//
//  Steam Buttons.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-20.
//

import SwiftUI

struct ImportFromSteamButton: View {
	@EnvironmentObject private var steam: SteamModel
	@EnvironmentObject private var library: LibraryModel
	@State private var task: Task<Void, Never>?

	init() { }

	var body: some View {
		AsyncButton("Import from Steam", task: $task) {
			await steam.importGames(using: library)
		}
		.disabled(task != nil)
	}

}
