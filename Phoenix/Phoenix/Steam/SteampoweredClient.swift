//
//  SteampoweredClient.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-20.
//

import Foundation

/// Undocumented API used by the Steam store.
public final class SteampoweredClient {
	//TODO: Try parsing .steam/appcache/appinfo.vdf and .steam/appcache/packageinfo.vdf
	// These seem to contain additional metadata

	static let shared: SteampoweredClient = {
		let client = SteampoweredClient()
		client.useDeviceInternationalization()
		return client
	}()

	internal static let url = URL(string: "https://store.steampowered.com/api/")!

	/// The URL session to use for requests
	public let session: URLSession

	/// The JSON decoder to use on responses
	public let decoder: JSONDecoder

	/// Two letter country code to select currency and date formats.
	public var region: String?

	/// Full name of the language to use for localized strings.
	public var language: String?

	public init(using session: URLSession = .shared) {
		self.session = session
		decoder = JSONDecoder()
	}

	/// Ensures the user's locale will be respected.
	public func useDeviceInternationalization() {
		region = Locale.current.region?.identifier
		if let lang = Locale.preferredLanguages.first {
			language = Locale.current.localizedString(forLanguageCode: lang)
		}
	}

	//MARK: - Endpoint Methods

	internal func execute(_ method: String, at path: String, query: [URLQueryItem?] = []) async throws -> Data {
		var endpoint = SteampoweredClient.url.appending(path: path, directoryHint: .notDirectory)

		var query = query.compactMap { $0 }
		if let region {
			query.append(URLQueryItem(name: "cc", value: region))
		}
		if let language {
			query.append(URLQueryItem(name: "l", value: language))
		}
		if !query.isEmpty {
			endpoint = endpoint.appending(queryItems: query)
		}

		var request = URLRequest(url: endpoint)
		request.httpMethod = method

		let (data, _) = try await session.data(for: request)
		return data
	}

	internal func execute<T: Decodable>(_ method: String, at path: String, query: [URLQueryItem?] = []) async throws -> T {
		let data = try await execute(method, at: path, query: query)
		return try decoder.decode(T.self, from: data)
	}

}

//MARK: - Application Details Service

extension SteampoweredClient {

	public func details(of ids: [Int], filter: [String]? = nil) async throws -> ApplicationsDetailsResponse {
		try await execute("GET", at: "appdetails", query: [
			URLQueryItem(name: "appids", value: ids.lazy.map(\.description).joined(separator: ",")),
			filter.flatMap { URLQueryItem(name: "filter", value: $0.joined(separator: ",")) },
		])
	}

	public func details(of id: Int, filter: [String]? = nil) async throws -> ApplicationDetailsResponse? {
		let result: ApplicationsDetailsResponse = try await execute("GET", at: "appdetails", query: [
			URLQueryItem(name: "appids", value: id.description),
			filter.flatMap { URLQueryItem(name: "filter", value: $0.joined(separator: ",")) },
		])
		return result.applications[id]
	}

}

public struct ApplicationsDetailsResponse: Decodable {

	var applications: [Int : ApplicationDetailsResponse] = [:]

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: AnyCodingKey.self)
		for key in container.allKeys {
			if let id = key.intValue {
				applications[id] = try container.decode(ApplicationDetailsResponse.self, forKey: key)
			}
		}
	}

}

public struct ApplicationDetailsResponse: Codable {
	var success: Bool
	var data: ApplicationInfo
}

public struct ApplicationInfo: Codable {

	/// The kind of application, one of `game`, `dlc`, `demo`, `advertising`, `mod` or `video`.
	var type: String

	var name: String

	var steam_appid: Int

	var required_age: Int

	var is_free: Bool

	var controller_support: String?

	var dlc: [Int]?

	/// Detailed description in HTML
	var detailed_description: String

	/// About the game in HTML
	var about_the_game: String

	/// Short description in HTML
	var short_description: String

	/// Shown for movies or demos.
	var fullgame: Fullgame?

	/// List of supported languages in HTML
	var supported_languages: String

	var header_image: URL
	var capsule_image: URL
	var capsule_imagev5: URL
	var website: URL?

	var pc_requirements: Requirements
	var mac_requirements: Requirements
	var linux_requirements: Requirements

	var legal_notice: String?
	var developers: [String]?
	var publishers: [String]?

	var demos: [Demo]?

	/// Omitted if free-to-play
	var price: PriceOverview?

	var packages: [Int]?
	var package_groups: [PackageGroup]
	var platforms: PlatformAvailability
	var metacritic: Metacritic?
	var categories: [Category]?
	var genres: [Genre]?
	var screenshots: [Screenshot]?
	var movies: [Movie]?
	var recommendations: RecommendationsSection?
	var achievements: AchievementsSection?
	var release_date: ReleaseDate
	var support_info: SupportInfo

	var background: URL
	var background_raw: URL?
	var content_descriptors: ContentDescriptors
	var reviews: String?

	struct Requirements: Codable {
		/// Minimum requirement in HTML
		var minimum: String
		/// Recommended requirement in HTML
		var recommended: String?

		init(from decoder: Decoder) throws {
			if var array = try? decoder.unkeyedContainer() {
				guard array.count != 0 else {
					minimum = ""
					return
				}
				print("WHAT EVEN IS HERE?")
				print(try array.decode(String.self))
			}

			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.minimum = try container.decode(String.self, forKey: .minimum)
			self.recommended = try container.decodeIfPresent(String.self, forKey: .recommended)
		}
	}

	struct Fullgame: Codable {
		var appid: String?
		/// Could be `Uninitialized`
		var name: String
	}

	struct Demo: Codable {
		var appid: Int?
		/// Notes the demo's restrictions
		var description: String
	}

	struct PriceOverview: Codable {
		/// The currency of the prices
		var currency: String
		/// Pre-discount price in cents
		var initial: Int
		/// Post-discount price in cents
		var final: Int
		var discount_percent: Int
		var initial_formatted: String
		var final_formatted: String
	}

	struct PackageGroup: Codable {
		/// Observed values: `default`, `subscriptions`
		var name: String

		var title: String

		var description: String

		/// If ``display_type`` is `1`, describes what the subscriptions represent.
		var selection_text: String

		/// Marketing text about the savings made
		var save_text: String

		/// Notes how the package should be displayed
		///
		/// When `0`, subscriptions should be displayed as separate purchase blocks.
		///
		/// When `1`, subcriptions should be displayed within a single purchase block using a picker.
		var display_type: Int

		/// `false` or `true`
		var is_recurring_subscription: String

		var subs: [Subscription]
	}

	struct Subscription: Codable {
		var packageid: Int
		var percent_savings_text: String
		var percent_savings: Int
		var option_text: String
		var option_description: String
		var can_get_free_license: String
		var is_free_license: Bool
		var price_in_cents_with_discount: Int
	}

	struct PlatformAvailability: Codable {
		var windows: Bool
		var mac: Bool
		var linux: Bool
	}

	struct Metacritic: Codable {
		var score: Int
		var url: URL
	}

	struct Category: Codable, Identifiable {
		var id: Int
		var description: String
	}

	struct Genre: Codable, Identifiable {
		/// String of a numeric id
		var id: String
		var description: String
	}

	struct Screenshot: Codable, Identifiable {
		var id: Int
		var path_thumbnail: URL
		var path_full: URL
	}

	struct Movie: Codable, Identifiable {
		var id: Int
		var name: String
		var thumbnail: URL
		var webm: MovieQualityIndex
		var mp4: MovieQualityIndex
		var highlight: Bool
	}

	struct MovieQualityIndex: Codable {
		var low: URL
		var max: URL

		enum CodingKeys: String, CodingKey {
			case low = "480"
			case max
		}
	}

	struct RecommendationsSection: Codable {
		var total: Int
	}

	struct AchievementsSection: Codable {
		var total: Int
		var highlighted: [HighlightedAchievement]
	}

	struct HighlightedAchievement: Codable {
		var name: String
		var path: URL
	}

	struct ReleaseDate: Codable {
		/// Wether the application hasn't already released.
		var coming_soon: Bool
		/// Formatted date, empty when unannouced
		var date: String
	}

	struct SupportInfo: Codable {
		var url: String
		var email: String
	}

	struct ContentDescriptors: Codable {
		var ids: [Int]
		var notes: String?
	}

}

