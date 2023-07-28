//
//  NavigationModel.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

final class NavigationModel: ObservableObject {

	@Published var path = NavigationPath()
	@Published var game: UUID?

}
