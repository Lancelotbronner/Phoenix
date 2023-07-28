//
//  CachedImageField.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct CachedImage: View {

	@EnvironmentObject private var cache: ImageCacheModel

	private let path: String

	init(at path: String) {
		self.path = path
	}

	var body: some View {
		if let image = cache.image(at: path) {
			image
				.resizable()
		} else {
			Image(systemName: "photo")
				.resizable()
				.redacted(reason: .placeholder)
		}
	}

}

struct CachedImageField<Label: View>: View {
	@EnvironmentObject private var cache: ImageCacheModel
	@Environment(\.imageScale) private var imageScale
	@State private var isImporterPresented = false

	private let label: Label
	private let path: String

	init(
		at path: String,
		@ViewBuilder label: () -> Label
	) {
		self.path = path
		self.label = label()
	}

	init(
		_ title: LocalizedStringKey,
		at path: String
	) where Label == Text {
		self.init(at: path) { Text(title) }
	}

	init(
		_ title: String,
		at path: String
	) where Label == Text {
		self.init(at: path) { Text(title) }
	}

	private var scale: CGFloat {
		switch imageScale {
		case .small: return 80
		case .medium: return 160
		case .large: return 320
		@unknown default: return 120
		}
	}

	var body: some View {
		LabeledContent {
			Button {
				isImporterPresented.toggle()
			} label: {
				if let image = cache.image(at: path) {
					ZStack {
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
							.frame(maxWidth: scale, maxHeight: scale)
						Image(systemName: "photo.badge.plus")
							.padding(scale / 10)
							.background(RoundedRectangle(cornerRadius: 4, style: .circular)
								.fill(Material.ultraThin.opacity(0.8)))
					}
				} else {
					Text("Browse...")
				}
			}
			.buttonStyle(.plain)
		} label: {
			label
		}
		.fileImporter(
			isPresented: $isImporterPresented,
			allowedContentTypes: [.image],
			allowsMultipleSelection: false
		) { result in
			do {
				guard let url = try result.get().first else { return }
				cache.cache(url, to: path)
			} catch {
				logger.write("[ERROR]: Failed to import image: \(error)")
			}
		}
	}

}
