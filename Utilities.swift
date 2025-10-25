//
//  Utilities.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import Foundation

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}
