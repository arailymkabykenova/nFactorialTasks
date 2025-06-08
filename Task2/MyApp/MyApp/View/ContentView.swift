//
//  ContentView.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 04.06.2025.
//

import SwiftUICore

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if viewModel.user != nil { 
            NavigationStack {
                TasksView(authViewModel: viewModel)
            }
        } else {
            NavigationStack {
                LoginView()
            }
        }
    }
}
