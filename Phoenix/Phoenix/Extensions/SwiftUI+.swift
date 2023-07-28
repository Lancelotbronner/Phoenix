//
//  SwiftUI+.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-14.
//

import SwiftUI

extension View {

	@ViewBuilder func validate(_ error: Text, when condition: Bool) -> some View {
		if condition {
			VStack(alignment: .leading) {
				self
				error
					.font(.caption)
					.foregroundStyle(.red)
			}
		} else {
			self
		}
	}

	func validate(_ error: LocalizedStringKey, when condition: Bool) -> some View {
		validate(Text(error), when: condition)
	}

	func validate(_ error: String, when condition: Bool) -> some View {
		validate(Text(error), when: condition)
	}

}

extension AttributedString {

	init?(html string: String) throws {
		guard let data = string.data(using: .utf8) else { return nil }
		let nsattributedstring = try? NSAttributedString(data: data, options: [
			.documentType: NSAttributedString.DocumentType.html.rawValue,
			.characterEncoding: String.Encoding.utf8.rawValue
		], documentAttributes: nil)
		guard let nsattributedstring else { return nil }
		self = AttributedString(nsattributedstring)
		_fixup()
	}

	mutating func _fixup() {
		let runs = runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self]
		for (block, range) in runs.reversed() {
			guard let block else { continue }
			for intent in block.components {
				switch intent.kind {
				case let .header(level):
					switch level {
					case 1: self[range].font = .largeTitle
					case 2: self[range].font = .title
					case 3: self[range].font = .title2
					case 4: self[range].font = .title3
					default: break
					}
				default: break
				}
			}
			if range.lowerBound != startIndex {
				characters.insert(contentsOf: "\n", at: range.lowerBound)
			}
		}
	}

}

func ?? <T: Equatable>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
	Binding {
		lhs.wrappedValue ?? rhs
	} set: {
		lhs.wrappedValue = $0 == rhs ? nil : $0
	}
}

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
	Binding { lhs.wrappedValue ?? rhs } set: { lhs.wrappedValue = $0 }
}

// In order to allow Date in @AppStorage
extension Date: RawRepresentable {
	public var rawValue: String {
		self.timeIntervalSinceReferenceDate.description
	}

	public init?(rawValue: String) {
		self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
	}
}
