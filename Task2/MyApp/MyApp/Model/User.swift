//
//  User.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 04.06.2025.
//
import Foundation
struct User:Codable{
    var firstName:String
    var lastName:String
    var nickname:String
    var password:String
    var tasks:[Task]
}
