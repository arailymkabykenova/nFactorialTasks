//
//  Task.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 04.06.2025.
//

import Foundation

struct Task: Codable, Identifiable, Hashable {
   
    let id: UUID
    var title: String 
    var isDone: Bool
}
