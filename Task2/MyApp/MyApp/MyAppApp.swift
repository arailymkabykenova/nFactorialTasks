//
//  MyAppApp.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 04.06.2025.
//

import SwiftUI

@main
struct MyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView() 
                .environmentObject(authViewModel)
        }
    }
}
