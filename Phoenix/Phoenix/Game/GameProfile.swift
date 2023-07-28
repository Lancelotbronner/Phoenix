//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameProfileView: View {
	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		GeometryReader { proxy in
			ScrollView(.vertical) {
				VStack(alignment: .trailing) {
					GameGenreView(game)
						.padding()
					Spacer()
					//TODO: Features such as singleplayer, multiplayer, controller, etc.
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
				.background {
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
				}
				.frame(height: 320)
				.overlay(GameLogoImage(game)
					.aspectRatio(contentMode: .fit)
					.frame(maxHeight: 150))
				
				LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
					Section {
						GameDetailsView($game)
					} header: {
						GamePlaybarView($game)
							.padding()
							.frame(height: 60)
							.background(Material.ultraThin)
					}
				}
				.frame(minHeight: proxy.size.height - 380, alignment: .top)
				.background(alignment: .top) {
					GameBannerImage(game)
						.aspectRatio(contentMode: .fill)
						.frame(maxHeight: .infinity, alignment: .top)
						.overlay(Gradient(colors: [.clear, .clear, .black]))
						.overlay(Material.regular)
						.scaleEffect(1.1, anchor: .top)
						.offset(x: 0, y: 60)
				}
			}
			.navigationTitle(game.name)
		}
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
