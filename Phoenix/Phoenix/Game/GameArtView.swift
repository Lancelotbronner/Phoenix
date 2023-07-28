//
//  Game ArtView.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

struct GameParallaxHeader: View {
	private let game: Game

	init(_ game: Game) {
		self.game = game
	}

	var body: some View {
		GeometryReader { geometry in
			CachedImage(at: ImageCacheModel.path(bannerOf: game))
				.aspectRatio(contentMode: .fill)
				.frame(width: geometry.size.width, height: height(geometry))
				.blur(radius: blur(geometry))
				.offset(x: 0, y: verticalOffset(geometry))
		}
		.ignoresSafeArea(.all)
	}

	/// Returns the vertical offset for a header image based on the given geometry.
	///
	/// If the given geometry has a positive vertical scroll offset (i.e. it has been
	/// pulled down), the returned offset will be the negative of the scroll offset.
	/// Otherwise, the returned offset will be 0.
	///
	/// - Parameters:
	///    - geometry: The geometry to use to calculate the offset.
	///
	/// - Returns: The vertical offset for a header image based on the given geometry.
	func verticalOffset(_ geometry: GeometryProxy) -> CGFloat {
		var offset = geometry.frame(in: .global).minY
		offset = offset > 0 ? -offset : 0
		return offset
	}

	/// Returns the height for a header image based on the given geometry.
	///
	/// If the given geometry has a positive vertical scroll offset (i.e. it has been
	/// pulled down), the returned height will be the height of the geometry plus the
	/// scroll offset. Otherwise, the returned height will be the height of the
	/// geometry.
	///
	/// - Parameters:
	///    - geometry: The geometry to use to calculate the height.
	///
	/// - Returns: The height for a header image based on the given geometry.
	func height(_ geometry: GeometryProxy) -> CGFloat {
		let offset = geometry.frame(in: .global).minY
		var height = geometry.size.height
		if offset > 0 {
			height += offset
		}
		return height
	}

	/// Returns the blur radius for an image based on the given geometry.
	///
	/// The blur radius is calculated as a percentage of the image height, with values
	/// ranging from 0 to 10. If the given geometry has a positive vertical scroll
	/// offset (i.e. it has been pulled down), the blur radius will increase as the
	/// offset increases. If the geometry has a negative or 0 offset, the blur radius
	/// will be 0.
	///
	/// - Parameters:
	///    - geometry: The geometry to use to calculate the blur radius.
	///
	/// - Returns: The blur radius for an image based on the given geometry.
	func blur(_ geometry: GeometryProxy) -> CGFloat {
		let offset = geometry.frame(in: .global).maxY
		guard offset > 0 else { return 10 }

		let height = geometry.size.height
		let blur = (height - max(offset, 0)) / height

		return blur * 10
	}

}
