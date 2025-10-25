//
//  ContentView.swift
//  Expense tracker
//
//  Created by dipanshu varshney
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var selectedPage = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedPage) {
                ExpenseListView(viewModel: viewModel)
                    .tag(0)
                    .tabItem { Label("Expenses", systemImage: "list.bullet") }

                ExpenseGraphView(viewModel: viewModel)
                    .tag(1)
                    .tabItem { Label("Graph", systemImage: "chart.bar.fill") }
                
                SettingsView(viewModel: viewModel)
                    .tag(2)
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            .tabViewStyle(.automatic)
            .navigationTitle("Expense Tracker")
        }
    }
}
