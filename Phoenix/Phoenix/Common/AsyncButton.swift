//
//  AsyncButton.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-20.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
	@Binding private var task: Task<Void, Never>?

	let action: () async -> Void
	let label: Label

	init(
		task: Binding<Task<Void, Never>?> = .constant(nil),
		action: @escaping () async -> Void,
		@ViewBuilder label: () -> Label
	) {
		_task = task
		self.action = action
		self.label = label()
	}

	init(
		_ title: LocalizedStringKey,
		task: Binding<Task<Void, Never>?> = .constant(nil),
		action: @escaping () async -> Void
	) where Label == Text {
		self.init(task: task, action: action) { Text(title) }
	}

	init(
		_ title: String,
		task: Binding<Task<Void, Never>?> = .constant(nil),
		action: @escaping () async -> Void
	) where Label == Text {
		self.init(task: task, action: action) { Text(title) }
	}

	var body: some View {
		Button {
			task = Task {
				await action()
				task = nil
			}
		} label: {
			label
		}
	}
}
