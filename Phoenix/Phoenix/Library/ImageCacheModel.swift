//
//  ImageCacheModel.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

final class ImageCacheModel: ObservableObject {

	private let url: URL

	init(at url: URL) {
		self.url = url
	}

	//MARK: - Banner Management

	func banner(for game: Game) -> Image? {
		image(at: ImageCacheModel.path(bannerOf: game))
	}

	func cache(header source: URL, for game: Game) {
		cache(source, to: ImageCacheModel.path(bannerOf: game))
	}

	static func path(bannerOf game: Game) -> String {
		"banners/\(game.id).png"
	}

	//MARK: - Header Management

	static func path(headerOf game: Game) -> String {
		"header/\(game.id).png"
	}

	//MARK: - Icon Management

	func icon(for game: Game) -> Image? {
		image(at: ImageCacheModel.path(iconOf: game))
	}

	func set(icon source: URL, for game: Game) {
		cache(source, to: ImageCacheModel.path(iconOf: game))
	}

	static func path(iconOf game: Game) -> String {
		"icon/\(game.id).png"
	}

	//MARK: - Library Management

	static func path(libraryOf game: Game) -> String {
		"library/\(game.id).png"
	}

	//MARK: - Logo Management

	static func path(logoOf game: Game) -> String {
		"logo/\(game.id).png"
	}

	//MARK: - Image Management

	func image(at path: String) -> Image? {
		let url = url.appending(component: path, directoryHint: .notDirectory)
		return NSImage(contentsOf: url).flatMap(Image.init)
	}

	func cache(_ source: URL, to path: String) {
		guard source.startAccessingSecurityScopedResource() else { return }
		defer { source.stopAccessingSecurityScopedResource() }

		do {
			guard let image = NSImage(contentsOf: source) else {
				logger.write("[ERROR]: Failed to load NSImage at \(source)")
				return
			}

			guard let data = image.tiffRepresentation else {
				logger.write("[ERROR]: Failed to convert NSImage at \(source) to TIFF")
				return
			}

			guard let bitmap = NSBitmapImageRep(data: data) else {
				logger.write("[ERROR]: Failed to convert TIFF image at \(source) to BITMAP")
				return
			}

			guard let png = bitmap.representation(using: .png, properties: [:]) else {
				logger.write("[ERROR]: Failed to convert BITMAP image at \(source) to PNG")
				return
			}

			let fileURL = url.appending(path: path, directoryHint: .notDirectory)
			let directoryURL = fileURL.deletingLastPathComponent()

			if !FileManager.default.fileExists(atPath: directoryURL.path()) {
				try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
			}

			try png.write(to: fileURL, options: .atomic)
		} catch {
			logger.write("[ERROR]: Failed to cache image from \(source): \(error)")
		}
	}

}
