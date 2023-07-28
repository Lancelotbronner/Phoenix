//
//  Game Commands.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameLabel: View {
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		Label {
			Text(game.name)
				.fontWeight(.light)
		} icon: {
			GameIconImage(game)
				.aspectRatio(contentMode: .fill)
				.clipShape(RoundedRectangle(cornerRadius: 4, style: .circular))
				.imageScale(.large)
		}
	}
}

struct PlayButton: View {
	@EnvironmentObject private var settings: PhoenixSettings
	@EnvironmentObject private var library: LibraryModel

	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		Menu {
			ForEach(game.profiles.dropFirst()) { profile in
				Button(profile.name) {
					try? game.launch(profile)
				}
			}
		} label: {
			Label {
				Text("Play")
					.fontWeight(.medium)
			} icon: {
				Image(systemName: "play.fill")
					.fontWeight(.bold)
			}
			.font(.title)
			.fontWeight(.light)
			.textCase(.uppercase)
			.foregroundStyle(.white.opacity(0.9))
			.padding(.vertical, 8)
			.padding(.horizontal, 40)
			.background(RoundedRectangle(cornerRadius: 4, style: .circular)
				.fill(Gradient(colors: [Color.green.opacity(0.7), Color.green.opacity(0.5)])))
		} primaryAction: {
			try? game.launch()
		}
		.buttonStyle(.plain)
	}
}

struct GameSettingsButton: View {
	@EnvironmentObject private var navigation: NavigationModel
	@EnvironmentObject private var settings: PhoenixSettings
	@EnvironmentObject private var library: LibraryModel
	@Environment(\.dismiss) private var dismiss
	@State var isEditorPresented = false

	private let game: Binding<Game>

	init(_ game: Binding<Game>) {
		self.game = game
	}

	var body: some View {
		NavigationLink {
			GameEditor(game)
		} label: {
			Image(systemName: "gearshape.fill")
				.imageScale(.large)
				.padding(8)
				.foregroundStyle(Color.gray.opacity(0.8))
				.background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 4, style: .circular))
		}
		.buttonStyle(.plain)
	}
}

struct GameBannerImage: View {
	@EnvironmentObject private var steam: SteamModel
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		if let url = game.banner, let image = Image(sandbox: url, access: steam.steamURL) {
			image
				.resizable()
		} else {
			CachedImage(at: ImageCacheModel.path(bannerOf: game))
		}
	}
}

struct GameIconImage: View {
	@EnvironmentObject private var steam: SteamModel
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		if let url = game.icon, let image = Image(sandbox: url, access: steam.steamURL) {
			image
				.resizable()
		} else {
			CachedImage(at: ImageCacheModel.path(iconOf: game))
		}
	}
}

struct GameLibraryImage: View {
	@EnvironmentObject private var steam: SteamModel
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		if let url = game.library, let image = Image(sandbox: url, access: steam.steamURL) {
			image
				.resizable()
		} else {
			CachedImage(at: ImageCacheModel.path(libraryOf: game))
		}
	}
}

struct GameLogoImage: View {
	@EnvironmentObject private var steam: SteamModel
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		if let url = game.logo, let image = Image(sandbox: url, access: steam.steamURL) {
			image
				.resizable()
		} else {
			CachedImage(at: ImageCacheModel.path(logoOf: game))
		}
	}
}
