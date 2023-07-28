//
//  AddGame Command.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct AddGameButton<Label: View>: View {

	@EnvironmentObject private var library: LibraryModel
	@EnvironmentObject private var navigation: NavigationModel

	@State private var isSheetPresented = false

	private let label: Label

	init(@ViewBuilder label: () -> Label) {
		self.label = label()
	}

	init() where Label == SwiftUI.Label<Text, Image> {
		self.init { SwiftUI.Label("Add Game", systemImage: "plus") }
	}

	var body: some View {
		Button {
			isSheetPresented.toggle()
		} label: {
			label
		}
		.sheet(isPresented: $isSheetPresented) {
			AddGameSheet()
				.environmentObject(library)
				.environmentObject(navigation)
		}
	}
}

