//
//  Buttons.swift
//  Task1
//
//  Created by Арайлым Кабыкенова on 03.06.2025.
//
import SwiftUI
struct Buttons:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.white)
            .opacity(1)
            .cornerRadius(9)
            .foregroundColor(Color(red:161/255,green:89/255,blue:216/255))
    }
}
