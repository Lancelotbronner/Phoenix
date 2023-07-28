//
//  IntervalPicker.swift
//  Phoenix
//
//  Created by Christophe Bronner on 2023-07-17.
//

import SwiftUI

struct IntervalPicker<Label: View>: View {

	@Binding private var value: TimeInterval
	private let label: Label

	init(
		selection: Binding<TimeInterval>,
		@ViewBuilder label: () -> Label
	) {
		_value = selection
		self.label = label()
	}

	init(_ title: LocalizedStringKey, selection: Binding<TimeInterval>) where Label == Text {
		self.init(selection: selection) { Text(title) }
	}

	init(_ title: String, selection: Binding<TimeInterval>) where Label == Text {
		self.init(selection: selection) { Text(title) }
	}

	var body: some View {
		Picker(selection: $value) {
			Text("Hourly")
				.tag(3_600.0)
			Text("Daily")
				.tag(86_400.0)
			Text("Weekly")
				.tag(604_800.0)
			Text("Monthly")
				.tag(2_629_800.0)
		} label: {
			label
		}
	}
}
