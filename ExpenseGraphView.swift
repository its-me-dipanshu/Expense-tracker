//
//  ExpenseGraphView.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//

import SwiftUI
import Charts

struct ExpenseGraphView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var expensesByMonth: [Expense] {
        viewModel.filterExpensesByMonth()
    }
    
    var groupedExpenses: [String: Double] {
        expensesByMonth.reduce(into: [String: Double]()) { result, expense in
            let categoryName = expense.category == .custom ? expense.customCategory ?? "Custom" : expense.category.rawValue
            result[categoryName, default: 0] += expense.amount
        }
    }
    
    var body: some View {
        VStack {
            Text("Monthly Expense Breakdown")
                .font(.title2).bold().padding(.top)

            if groupedExpenses.isEmpty {
                ContentUnavailableView("No Expenses This Month", systemImage: "chart.bar.fill")
            } else {
                Chart {
                    ForEach(groupedExpenses.sorted(by: { $0.key < $1.key }), id: \.key) { category, totalAmount in
                        BarMark(
                            x: .value("Category", category),
                            y: .value("Amount", totalAmount)
                        )
                        .foregroundStyle(by: .value("Category", category))
                    }
                    
                    RuleMark(
                        y: .value("Monthly Limit", viewModel.monthlyLimit)
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Limit: ₹\(viewModel.monthlyLimit, specifier: "%.0f")")
                            .font(.caption).bold()
                            .foregroundColor(.red)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .automatic)
                }
                .frame(height: 300)
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}
