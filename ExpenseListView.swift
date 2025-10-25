//
//  ExpenseListView.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//


import SwiftUI

struct ExpenseListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showAddExpense = false
    @State private var expenseToEdit: Expense? = nil
    @State private var showAlert = false

    var body: some View {
        VStack {
            // Total Expense Card
            VStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("Total Spent (Filtered)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("₹\(viewModel.getTotalExpense(), specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding([.horizontal, .top])
            
            
            HStack {
                Text("Filter Date:")
                
                DatePicker("Select Date", selection: Binding(
                    get: { viewModel.selectedDate ?? viewModel.selectedMonth ?? Date() },
                    set: {
                        viewModel.selectedDate = $0
                        viewModel.selectedMonth = $0
                    }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                
                if viewModel.selectedDate != nil {
                    Button("Clear Day") {
                        withAnimation {
                            viewModel.selectedDate = nil
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Button("View All") {
                    withAnimation {
                        viewModel.selectedDate = nil
                        viewModel.selectedMonth = nil
                    }
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding(.horizontal)

            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filterExpensesByDate(), id: \.id) { expense in
                        ExpenseCardView(expense: expense)
                            .onTapGesture {
                                expenseToEdit = expense
                                showAddExpense = true
                            }
                            .contextMenu {
                                Button("Edit") {
                                    expenseToEdit = expense
                                    showAddExpense = true
                                }
                                Button("Delete", role: .destructive) {
                                    if let index = viewModel.expenses.firstIndex(where: { $0.id == expense.id }) {
                                        viewModel.expenses.remove(at: index)
                                    }
                                }
                            }
                    }
                    .onDelete(perform: viewModel.removeExpense)
                }
                .padding(.horizontal)
            }
            .animation(.easeInOut, value: viewModel.expenses)
            
            .onAppear {
                showAlert = viewModel.checkMonthlyLimit()
            }
            .onChange(of: viewModel.expenses) { _, _ in
                showAlert = viewModel.checkMonthlyLimit()
            }
            .onChange(of: viewModel.selectedMonth) { _, _ in
                showAlert = viewModel.checkMonthlyLimit()
            }
            .alert("Limit Exceeded!", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your total expense for this month (₹\(viewModel.filterExpensesByMonth().reduce(0) { $0 + $1.amount }, specifier: "%.2f")) has exceeded your limit (₹\(viewModel.monthlyLimit, specifier: "%.2f")).")
            }

            
            Button {
                expenseToEdit = nil
                showAddExpense = true
            } label: {
                Label("Add New Expense", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(viewModel: viewModel, expense: expenseToEdit)
        }
    }
    
    struct ExpenseCardView: View {
        let expense: Expense
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(expense.name)
                        .font(.headline)
                    Text("\(expense.category == .custom ? expense.customCategory ?? "Custom" : expense.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("₹\(expense.amount, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text(formatDate(expense.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            #if os(macOS)
            .background(Color(NSColor.windowBackgroundColor))
            #else
            .background(Color(.systemBackground))
            #endif
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}
