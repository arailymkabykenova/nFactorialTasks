//
//  Characters.swift
//  CharacterCatalog
//
//  Created by Арайлым Кабыкенова on 06.06.2025.
//

struct APIResponse<T: Codable>: Codable {
    let info: Info
    let results: [T]
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
struct Characters:Codable,Identifiable{
        
        let id: Int
        let name: String
        let status: Status
        let gender: Gender
        let image: String
        let location: CharacterLocation
    }

    enum Status: String, Codable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }

    enum Gender: String, Codable {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case unknown = "unknown"
    }

    struct CharacterLocation: Codable {
        let name: String
        let url: String

}

