//
//  CharacterService.swift
//  CharacterCatalog
//
//  Created by Арайлым Кабыкенова on 06.06.2025.
//
import Foundation
class CharacterService{
    private let netService=NetworkService()
    
    func get() async throws -> [Characters] {
        
        let response:APIResponse<Characters> = try await netService.get(relativePath: "/character")
        
        return response.results
    }
}
