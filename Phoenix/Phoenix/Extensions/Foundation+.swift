//
//  Foundation+.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import Foundation

extension URL {

	static let homeDirectory: URL = {
		let pw = getpwuid(getuid())
		guard let cpath = pw?.pointee.pw_dir else {
			fatalError("Unable to retrieve the real home directory")
		}

		let path = FileManager.default.string(withFileSystemRepresentation: cpath, length: Int(strlen(cpath)))
		return URL(fileURLWithPath: path, isDirectory: true)
	}()

}

extension AttributedString {

	var stringValue: String {
		_read { yield description }
		set {
			replaceSubrange(startIndex..<endIndex, with: AttributedString(newValue))
		}
	}

}
