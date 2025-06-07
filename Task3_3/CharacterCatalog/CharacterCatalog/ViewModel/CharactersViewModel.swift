//
//  CharactersViewModel.swift
//  CharacterCatalog
//
//  Created by Арайлым Кабыкенова on 06.06.2025.
//

import Foundation
@MainActor
class CharactersViewModel:ObservableObject {
    private let characterService=CharacterService()
    @Published var characters:[Characters] = []
    @Published var isLoading:Bool = false
    @Published var errorDescription:String?
    
    func fetchCharacters() async{
        
        isLoading = true
        
        do{
            
            characters=try await characterService.get()
        }catch{
            
            errorDescription=error.localizedDescription
        }
        
        isLoading=false
    }
    
}
