//
//  Game.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import SwiftUI

struct Game: Identifiable, Codable, Hashable {

	private(set) var id = UUID()

	var isInvalid: Bool {
		(profiles.first?.command.isEmpty ?? true) || name.isEmpty
	}

	//MARK: - Profile Management

	/// Profiles have customized launch arguments
	var profiles: [Profile] = []

	mutating func launch(_ profile: Profile) throws {
		lastPlayed = .now
		try Terminal.shell(profile.command)
	}

	mutating func launch() throws {
		guard let profile = profiles.first else { return }
		try launch(profile)
	}

	//MARK: - Metadata Management

	var name = ""
	var rating: String?
	var releaseDate: Date?
	var lastPlayed: Date?
	var developer: String?
	var summary: AttributedString?
	var details: AttributedString?
	var genre: String?
	var feature: String?
	var publisher: String?

	var ratingAsPercent: Float? {
		get { rating.flatMap { Float($0) ?? 0 } }
		set { rating = newValue.flatMap { Int($0).description } }
	}

	var genres: [Substring] {
		genre?.split {
			$0 == "\n" || $0 == ","
		} ?? []
	}

	var features: [Substring] {
		feature?.split {
			$0 == "\n" || $0 == ","
		} ?? []
	}

	//MARK: - Artwork Management

	var banner: URL?
	var header: URL?
	var icon: URL?
	var library: URL?
	var logo: URL?

	//MARK: - Platform Management

	var steam: SteamMetadata?

	var isSteam: Bool {
		steam != nil
	}

	//MARK: - Preferences Management

	var isDeleted = false

	@ViewBuilder var label: some View {
		if isSteam {
			Text("Steam")
		}
		Text("Other")
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}

}
