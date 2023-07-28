//
//  Profile.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-20.
//

import Foundation

/// Encapsulates the information about a game's launch
struct Profile: Codable, Hashable, Identifiable {

	private(set) var id = UUID()

	/// The name of the profile
	var name: String

	/// The command to launch this profile
	var command: String

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Profile, rhs: Profile) -> Bool {
		lhs.id == rhs.id
	}

}
