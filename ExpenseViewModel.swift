//
//  ExpenseViewModel.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import SwiftUI
import Combine
import Foundation

final class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet {
            saveExpenses()
        }
    }
    @Published var monthlyLimit: Double = 500 {
        didSet {
            saveLimit()
        }
    }
    @Published var selectedMonth: Date? = Date()
    @Published var selectedDate: Date? = nil

    init() {
        loadExpenses()
        loadLimit()
        
        if expenses.isEmpty {
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            
            let sampleExpenses = [
                Expense(id: UUID(), name: "Big Shopping", amount: 3000, date: today, category: .shopping, customCategory: nil),
                Expense(id: UUID(), name: "Trip Ticket", amount: 2000, date: today, category: .travel, customCategory: nil),
                Expense(id: UUID(), name: "Rent Share", amount: 1000, date: yesterday, category: .other, customCategory: nil),
                Expense(id: UUID(), name: "Dinner", amount: 500, date: yesterday, category: .food, customCategory: nil)
            ]
            self.expenses = sampleExpenses
        }
        sortExpensesByDateDesc()
    }
    
    private var fileURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent("expenses.data")
    }
    
    private let limitKey = "MonthlyLimit"
    
    func saveLimit() {
        UserDefaults.standard.set(monthlyLimit, forKey: limitKey)
    }
    
    func loadLimit() {
        let savedLimit = UserDefaults.standard.double(forKey: limitKey)
        if savedLimit == 0 && UserDefaults.standard.object(forKey: limitKey) == nil {
             self.monthlyLimit = 500
        } else {
             self.monthlyLimit = savedLimit
        }
    }

    func saveExpenses() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(expenses)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save expenses: \(error.localizedDescription)")
        }
    }

    func loadExpenses() {
        guard let url = fileURL else { return }
        do {
            let data = try Data(contentsOf: url)
            let decodedExpenses = try JSONDecoder().decode([Expense].self, from: data)
            self.expenses = decodedExpenses
        } catch {
            self.expenses = []
        }
    }
    
    func checkMonthlyLimit() -> Bool {
        let currentMonthTotal = filterExpensesByMonth().reduce(0) { $0 + $1.amount }
        return currentMonthTotal > monthlyLimit
    }
    
    func filterExpensesByDate() -> [Expense] {
        guard let selectedMonth = selectedMonth else {
            return expenses
        }
        
        let calendar = Calendar.current
        
        if let selectedDate = selectedDate {
            return expenses.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        }
        
        let selMonth = calendar.component(.month, from: selectedMonth)
        let selYear = calendar.component(.year, from: selectedMonth)
        return expenses.filter {
            let expenseMonth = calendar.component(.month, from: $0.date)
            let expenseYear = calendar.component(.year, from: $0.date)
            return expenseMonth == selMonth && expenseYear == selYear
        }
    }
    
    func filterExpensesByMonth() -> [Expense] {
        let calendar = Calendar.current
        
        let monthToFilter = selectedMonth ?? Date()
        
        let selMonth = calendar.component(.month, from: monthToFilter)
        let selYear = calendar.component(.year, from: monthToFilter)
        
        return expenses.filter {
            let expenseMonth = calendar.component(.month, from: $0.date)
            let expenseYear = calendar.component(.year, from: $0.date)
            return expenseMonth == selMonth && expenseYear == selYear
        }
    }
    
    func getTotalExpense() -> Double {
        filterExpensesByDate().reduce(0) { $0 + $1.amount }
    }

    func addExpense(name: String, amount: Double, date: Date, category: ExpenseCategory, customCategory: String?) {
        let sanitizedCustom = (category == .custom) ? (customCategory?.trimmingCharacters(in: .whitespacesAndNewlines)) : nil
        let newExpense = Expense(id: UUID(), name: name, amount: amount, date: date, category: category, customCategory: sanitizedCustom)
        withAnimation(.spring()) {
            expenses.insert(newExpense, at: 0)
            sortExpensesByDateDesc()
        }
    }

    func editExpense(expense: Expense, name: String, amount: Double, date: Date, category: ExpenseCategory, customCategory: String?) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        let sanitizedCustom = (category == .custom) ? (customCategory?.trimmingCharacters(in: .whitespacesAndNewlines)) : nil
        let updated = Expense(id: expense.id, name: name, amount: amount, date: date, category: category, customCategory: sanitizedCustom)
        withAnimation {
            expenses[index] = updated
            sortExpensesByDateDesc()
        }
    }

    func removeExpense(at offsets: IndexSet) {
        withAnimation(.easeOut(duration: 0.5)) {
            let filteredExpenses = filterExpensesByDate()
            let indicesToRemove = offsets.map { filteredExpenses[$0] }
            
            for expenseToRemove in indicesToRemove {
                if let index = expenses.firstIndex(where: { $0.id == expenseToRemove.id }) {
                    expenses.remove(at: index)
                }
            }
        }
    }

    private func sortExpensesByDateDesc() {
        expenses.sort { $0.date > $1.date }
    }
}
