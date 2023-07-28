//
//  AnyCodingKey.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-20.
//

internal enum AnyCodingKey: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
	case identifier(String)
	case index(Int)

	init(stringValue: String) {
		self = .identifier(stringValue)
	}

	init(stringLiteral value: String) {
		self.init(stringValue: value)
	}

	init(intValue: Int) {
		self = .index(intValue)
	}

	init(integerLiteral value: Int) {
		self.init(intValue: value)
	}

	var intValue: Int? {
		switch self {
		case let .identifier(value): return Int(value)
		case let .index(value): return value
		}
	}

	var stringValue: String {
		switch self {
		case let .identifier(value): return value
		case let .index(value): return value.description
		}
	}

}

