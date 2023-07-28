//
//  SandboxManager.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

final class SandboxManager {
	//TODO: Stored bookmarks don't seem to work?

	static let shared = SandboxManager()

	private init() {
//		restore()
	}

	//MARK: - Bookmark Management

	@AppStorage("bookmarks")
	private var data: Data?

	private var bookmarks: [URL : Data] = [:]

	private func restore(_ url: URL) throws -> URL? {
		var isStale = false
		if let data = bookmarks[url], let restored = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &isStale) {
			if isStale {
				try store(restored, for: url)
			}
			return restored
		}
		return nil
	}

	private func store(_ value: URL, for key: URL) throws {
		bookmarks[key] = try value.bookmarkData(options: [.withSecurityScope])
		persist()
	}

	private func restore() {
		guard let data else { return }
		do {
			bookmarks = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSURL.self, NSData.self], from: data) as! [URL : Data]
		} catch {
			logger.write("[ERROR]: Failed to restore security bookmarks: \(error)")
		}
	}

	private func persist() {
		do {
			data = try NSKeyedArchiver.archivedData(withRootObject: bookmarks, requiringSecureCoding: false)
		} catch {
			logger.write("[ERROR]: Failed to persist security bookmarks: \(error)")
		}
	}

	//MARK: - Request Management

	@MainActor private func request(_ url: URL) throws -> URL? {
		let request = _SandboxAccessRequest(to: url)
		if let scope = request.execute() {
			try store(scope, for: url)
			return scope
		}
		return nil
	}

	//MARK: - URL Management

	@MainActor func _access<T>(_ url: URL, perform: (URL) throws -> T) rethrows -> T? {
		var scope: URL?
		do {
			scope = try restore(url)
			if scope == nil {
				scope = try request(url)
			}
		} catch {
			logger.write("[ERROR]: Could not access \(url) within security-scoped: \(error)")
		}

		if let scope, scope.startAccessingSecurityScopedResource() {
			defer { scope.stopAccessingSecurityScopedResource() }
			return try perform(scope)
		}

		return nil
	}

	@MainActor func access<T>(_ url: URL, perform: (URL) throws -> T?) rethrows -> T? {
		try _access(url, perform: perform)?.flatMap { $0 }
	}

	@MainActor func access<T>(_ url: URL, perform: @escaping (URL) async -> T) async -> T? {
		let tmp = _access(url) { url in
			Task { await perform(url) }
		}
		if let tmp {
			return await tmp.value
		}
		return nil
	}

	func access<T>(_ url: URL, perform: @escaping (URL) async -> T?) async -> T? {
		await access(url, perform: perform).flatMap { $0 }
	}

}

private final class _SandboxAccessRequest: NSObject, NSOpenSavePanelDelegate {
	private let url: URL

	init(to url: URL) {
		self.url = url.resolvingSymlinksInPath()
	}

	@MainActor func execute() -> URL? {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = true
		openPanel.canChooseFiles = false
		openPanel.canCreateDirectories = false
		openPanel.directoryURL = url
		openPanel.delegate = self

		var result = NSApplication.ModalResponse.cancel
		result = openPanel.runModal()
		return result == .OK ? openPanel.url : nil
	}

	func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
		self.url == url
	}

}
