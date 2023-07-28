//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameDetailsView: View {
	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		GameInformationView(game)
			.padding()
			.frame(height: 200)
			.background(Material.ultraThick, in: .rect(cornerRadius: 8))
			.padding()

		if let description = game.details {
			Text(description)
				.fontDesign(.default)
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(Material.thick, in: .rect(cornerRadius: 8))
				.padding()
		}
	}
}

struct GameInformationView: View {
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		HStack(alignment: .top, spacing: 20) {
			GameLibraryImage(game)
				.aspectRatio(3/4, contentMode: .fit)
				.clipShape(RoundedRectangle(cornerRadius: 4, style: .circular))
				.frame(maxHeight: 180)

			Text(game.summary ?? "")
				.fontWeight(.light)
				.fontDesign(.default)
				.minimumScaleFactor(0.25)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)

			Spacer()

			Grid(verticalSpacing: 4) {
				if let developer = game.developer {
					row("Developer", value: developer)
				}
				if let publisher = game.publisher {
					row("Publisher", value: publisher)
				}
				if let releaseDate = game.releaseDate {
					row("Release Date", value: releaseDate.formatted(date: .long, time: .omitted))
				}
				HStack {
					//TODO: Social links here
				}
				.gridCellUnsizedAxes(.horizontal)
				Divider()
					.gridCellUnsizedAxes(.horizontal)
				if let rating = game.ratingAsPercent {
					row("Rating", value: rating.formatted(.percent))
				}
			}
		}
	}

	func row(_ title: LocalizedStringKey, value: String) -> some View {
		GridRow {
			Text(title)
				.foregroundStyle(.secondary)
				.gridColumnAlignment(.trailing)
			Text(value)
				.gridColumnAlignment(.leading)
		}
	}
}

