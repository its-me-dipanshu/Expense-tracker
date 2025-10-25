//
//  Expense.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food = "Food"
    case shopping = "Shopping"
    case travel = "Travel"
    case other = "Other"
    case custom = "Custom"
    
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

struct Expense: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var customCategory: String?
}
