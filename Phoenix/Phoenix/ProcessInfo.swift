//
//  ProcessInfo.swift
//  Phoenix
//
//  Created by james on 6/24/23.
//

import Foundation

extension ProcessInfo {
    static var env: [String: String] {
        return ProcessInfo.processInfo.environment
    }
}
