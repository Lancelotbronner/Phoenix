//
//  Game EditorView.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import Foundation
import SwiftUI

struct GameEditor: View {
	@Binding private var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		Form {
			Section("Metadata") {
				GameMetadataEditor($game)
			}
			Section("Artwork") {
				GameArtworkEditor($game)
					.imageScale(.small)
			}
			Section("Preferences") {
				GamePreferencesEditor($game)
			}
			Section("Profiles") {
				GameProfilesEditor($game)
			}
		}
		.formStyle(.grouped)
		.navigationTitle(game.name)
	}

}

struct GameProfilesEditor: View {
	@Binding var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		if game.profiles.isEmpty {
			Text("This game has no profiles. You'll need one in order to launch the game.")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		List($game.profiles, editActions: .all) { $profile in
			NavigationLink {
				ProfileEditor($profile)
					.formStyle(.grouped)
			} label: {
				Group {
					if profile.name.isEmpty {
						Text("Unnamed Profile")
					} else {
						Text(profile.name)
					}
				}
				.font(profile.id == game.profiles.first?.id ? .headline : nil)
			}
			.contextMenu {
				Button("Delete") {
					if let i = game.profiles.firstIndex(of: profile) {
						game.profiles.remove(at: i)
					}
				}
			}
		}
		.padding(.vertical)
		Button{
			game.profiles.append(Profile(name: "", command: ""))
		} label: {
			Label("Add Profile", systemImage: "plus")
				.foregroundStyle(Color.accentColor)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
		}
		.buttonStyle(.plain)
	}
}

struct ProfileEditor: View {
	@Binding var profile: Profile

	init(_ profile: Binding<Profile>) {
		_profile = profile
	}

	var body: some View {
		Form {
			TextField("Name", text: $profile.name, prompt: Text("MyProfile"))
			TextField("Launch Command", text: $profile.command, prompt: Text("open /Applications/MyGame.app"))
				.help("Command used when launching the game.")
				.validate("This field is required", when: profile.command.isEmpty)
		}
		.navigationTitle(profile.name.isEmpty ? Text("Unnamed Profile") : Text(profile.name))
	}
}

struct GameMetadataEditor: View {
	@Binding var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		TextField("Name", text: $game.name, prompt: Text("display name"))
			.help("Name used in the sidebar and toolbar")
			.validate("This field is required", when: game.name.isEmpty)

//		TextField("Summary", text: $game.short ?? "", prompt: Text("summary of the game"), axis: .vertical)
//			.lineLimit(4...)
//			.multilineTextAlignment(.leading)
//
//		TextField("Description", text: $game.long ?? "", prompt: Text("store description of the game"), axis: .vertical)
//			.lineLimit(4...)
//			.multilineTextAlignment(.leading)
//
//		TextField("About the Game", text: $game.about ?? "", prompt: Text("store description of the game"), axis: .vertical)
//			.lineLimit(4...)
//			.multilineTextAlignment(.leading)

		TextField("Genre", text: $game.genre ?? "", prompt: Text("action, adventure"))

		TextField("Developer", text: $game.developer ?? "", prompt: Text("Developer Inc."))

		TextField("Publisher", text: $game.publisher ?? "", prompt: Text("Publisher Ltd."))

		DatePicker("Release Date", selection: $game.releaseDate ?? Date(), in: ...Date.now, displayedComponents: .date)
	}
}

struct GameArtworkEditor: View {
	@Binding var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		CachedImageField("Banner", at: ImageCacheModel.path(bannerOf: game))
			.help("Displayed in related background")

		CachedImageField("Icon", at: ImageCacheModel.path(iconOf: game))
			.help("Displayed in lists like the sidebar")

		CachedImageField("Library", at: ImageCacheModel.path(libraryOf: game))
			.help("Displayed in cards like genre collections")

		CachedImageField("Logo", at: ImageCacheModel.path(logoOf: game))
			.help("Displayed in the game's detail view")
	}
}

struct GamePreferencesEditor: View {
	@Binding var game: Game

	init(_ game: Binding<Game>) {
		_game = game
	}

	var body: some View {
		TextField("Rating", value: $game.ratingAsPercent, format: .percent, prompt: Text("100%"))
	}
}
