//
//  Buttons.swift
//  SosApp
//
//  Created by Арайлым Кабыкенова on 02.06.2025.
//
import SwiftUI
struct Buttons:ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .frame(width:200,height:50,alignment:.center)
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(5)
    }
}
struct textStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, design: .default))
            .frame(width: 300, height: 50,alignment: .leading)
    }
}
                    
