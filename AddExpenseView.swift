//
//  AddExpenseView.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    var expense: Expense? = nil

    @State private var name = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category: ExpenseCategory = .other
    @State private var customCategory = ""
    @Environment(\.dismiss) var dismiss

    init(viewModel: ExpenseViewModel, expense: Expense? = nil) {
        self.viewModel = viewModel
        self.expense = expense
        _name = State(initialValue: expense?.name ?? "")
        _amountText = State(initialValue: expense != nil ? String(format: "%.2f", expense!.amount) : "")
        _date = State(initialValue: expense?.date ?? Date())
        _category = State(initialValue: expense?.category ?? .other)
        _customCategory = State(initialValue: expense?.customCategory ?? "")
    }

    var body: some View {
        VStack(spacing: 20) {
            
            Text(expense == nil ? "Add New Expense" : "Edit Expense")
                .font(.title2).bold()
            
            VStack(spacing: 15) {
                TextField("Name of Expense", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Amount (₹)", text: $amountText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .onChange(of: amountText) { _, newValue in
                        amountText = filteredAmountInput(newValue)
                    }

                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { c in
                        Text(c.displayName).tag(c)
                    }
                }
                .pickerStyle(.menu)

                if category == .custom {
                    TextField("Custom category name", text: $customCategory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 15) {
                Button("Cancel") { dismiss() }
                .buttonStyle(.bordered)
                
                Button(expense == nil ? "Save Expense" : "Update Expense") { saveAction() }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
        }
        .padding()
        .frame(minWidth: 340)
    }

    private var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let value = Double(amountText), value > 0 else { return false }
        return true
    }

    private func saveAction() {
        guard let value = Double(amountText) else { return }

        if let exp = expense {
            viewModel.editExpense(expense: exp,
                                  name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                  amount: value,
                                  date: date,
                                  category: category,
                                  customCategory: category == .custom ? customCategory.trimmingCharacters(in: .whitespacesAndNewlines) : nil)
        } else {
            viewModel.addExpense(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                 amount: value,
                                 date: date,
                                 category: category,
                                 customCategory: category == .custom ? customCategory.trimmingCharacters(in: .whitespacesAndNewlines) : nil)
        }
        dismiss()
    }

    private func filteredAmountInput(_ input: String) -> String {
        var filtered = input.filter { "0123456789.".contains($0) }
        
        if filtered.components(separatedBy: ".").count > 2 {
            let parts = filtered.components(separatedBy: ".")
            filtered = parts.first! + "." + parts.dropFirst().joined()
        }
        
        return filtered
    }
}
