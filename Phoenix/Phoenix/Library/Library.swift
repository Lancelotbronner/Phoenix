//
//  LibraryModel.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

struct Library {

	/// The current format of the library
	static let format = 0

	/// The format of the library, used to migrate as it evolves
	var format: Int

	/// The games contained in this library
	var games: [Game] = []

	init() {
		format = Library.format
	}

}

//MARK: - Codable

extension Library: Codable {

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let format = try container.decodeIfPresent(Int.self, forKey: .format) ?? 0
		self.format = Library.format

		switch format {
		case 0:
			games = try container.decode([Game].self, forKey: .games)
		default:
			let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported format version \(format)")
			throw DecodingError.typeMismatch(Library.self, context)
		}
	}

}
