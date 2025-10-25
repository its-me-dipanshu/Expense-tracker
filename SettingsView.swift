//
//  SettingsView.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var limitText: String

    init(viewModel: ExpenseViewModel) {
        self.viewModel = viewModel
        _limitText = State(initialValue: String(format: "%.0f", viewModel.monthlyLimit))
    }

    var body: some View {
        Form {
            Section(header: Text("Monthly Budget Limit").font(.headline)) {
                HStack {
                    Text("Limit Amount (₹)")
                    Spacer()
                    TextField("", text: $limitText)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .textFieldStyle(.roundedBorder)
                }
                .onChange(of: limitText) { _, newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    limitText = filtered
                    if let value = Double(filtered) {
                        viewModel.monthlyLimit = value
                    }
                }
                
                Text("Current Monthly Limit: **₹\(viewModel.monthlyLimit, specifier: "%.0f")**")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
        .padding()
        .frame(minWidth: 300)
    }
}
