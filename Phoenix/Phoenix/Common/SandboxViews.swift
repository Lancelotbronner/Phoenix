//
//  SandboxManager.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

extension Image {

	@MainActor init?(sandbox contents: URL, access: URL) {
		let nsimage = SandboxManager.shared.access(access) { _ in
			NSImage(contentsOf: contents)
		}
		guard let nsimage else { return nil }
		self.init(nsImage: nsimage)
	}

}
