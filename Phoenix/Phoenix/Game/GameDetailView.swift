//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameDetailView: View {

	@EnvironmentObject private var settings: PhoenixSettings
	@EnvironmentObject private var library: LibraryModel

	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		ScrollView(.vertical) {
			LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
				VStack(alignment: .trailing) {
					GameGenreView(game)
						.padding()
					Spacer()
					//TODO: Features such as singleplayer, multiplayer, controller, etc.
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				.frame(height: 320)
				.overlay(GameLogoImage(game)
					.aspectRatio(contentMode: .fit)
					.frame(maxHeight: 150))

				Section {
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
							.background(Material.regular, in: .rect(cornerRadius: 8))
							.padding()
					}
				} header: {
					GamePlaybarView($game)
						.padding()
						.frame(height: 60)
						.background(Material.ultraThin)
				}
			}
			.frame(maxHeight: .infinity, alignment: .top)
			.background(alignment: .top) {
				VStack(spacing: 0) {
					GeometryReader { geometry in
						ZStack {
							GameBannerImage(game)
								.aspectRatio(contentMode: .fill)
								.frame(width: geometry.size.width)
							Rectangle()
								.fill(Gradient(colors: [.clear, .clear, .black]))
						}
						.offset(x: 0, y: -geometry.frame(in: .global).origin.y / 2)
					}
					.frame(height: 320)

					GameBannerImage(game)
						.aspectRatio(contentMode: .fill)
						.overlay(Material.ultraThin)
				}
			}
		}
		.navigationTitle(game.name)
	}

}

struct GameGenreView: View {
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		HStack {
			ForEach(game.genres, id: \.self) { genre in
				Text(genre)
					.font(.subheadline)
					.textCase(.uppercase)
					.foregroundStyle(.secondary)
					.padding(.vertical, 2)
					.padding(.horizontal, 6)
					.background(Material.ultraThin.opacity(0.5))
					.border(Color.white.opacity(0.1))
			}
		}
	}
}

struct GamePlaybarView: View {
	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		HStack(spacing: 20) {
			PlayButton($game)
			//TODO: Cloud status
			VStack(alignment: .leading) {
				Text("Last Played")
					.font(.headline)
					.foregroundStyle(Color.primary.opacity(0.6))
				Group {
					if let lastPlayed = game.lastPlayed {
						Text(lastPlayed.formatted(date: .long, time: .omitted))
					} else {
						Text("Never")
					}
				}
				.font(.subheadline)
				.foregroundStyle(Color.primary.opacity(0.4))
			}
			.textCase(.uppercase)
			.fontWeight(.regular)
			// TODO: Play time
			Spacer()
			GameSettingsButton($game)
			//TODO: Favorite button
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
