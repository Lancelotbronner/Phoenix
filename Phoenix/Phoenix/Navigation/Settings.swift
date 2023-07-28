//
//  Settings.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

final class PhoenixSettings: ObservableObject {

	static let shared = PhoenixSettings()

	//MARK: - Appearance Settings

	@AppStorage("accentColorUI")
	var isAccentColorEnabled: Bool = true

	private init() { }

}
