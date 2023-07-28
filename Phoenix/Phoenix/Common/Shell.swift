//
//  CmdUtils.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-24.
//

import Cocoa

struct Terminal {
	private init() { }
	
	/// Executes a shell command using zsh.
	///
	/// - Parameters:
	///   - command: The command to execute.
	public static func shell(_ command: String) throws {
		let task = Process()
		let pipe = Pipe()

		task.arguments = ["-c", command]
		task.executableURL = URL(fileURLWithPath: "/bin/zsh")
		task.standardInput = nil
		task.standardOutput = pipe
		task.standardError = pipe

		logger.write("[INFO]: zsh \(command)")
		try task.run()

		pipe.fileHandleForReading.readabilityHandler = { fileHandle in
			guard let line = String(data: fileHandle.availableData, encoding: .utf8) else { return }
			print(line, terminator: "")
		}
	}

}
