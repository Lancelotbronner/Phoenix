//
//  SteamAppManifest.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import Foundation

struct SteamAppManifest {

	static let parseKeyValuePair = /"([^"]+?)"\s*"([^"]*)"/

	private var pairs: [String : String] = [:]

	init(contentsOf url: URL) throws {
		let contents = try String(contentsOf: url)
		for match in contents.matches(of: SteamAppManifest.parseKeyValuePair) {
			pairs[String(match.output.1)] = String(match.output.2)
		}
	}

	subscript(_ key: String) -> String? {
		_read { yield pairs[key] }
	}

}
