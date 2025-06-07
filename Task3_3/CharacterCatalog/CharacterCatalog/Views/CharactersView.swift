//
//  CharactersView.swift
//  CharacterCatalog
//
//  Created by Арайлым Кабыкенова on 06.06.2025.
//

import SwiftUI

struct CharactersView: View {
    @StateObject var viewModel = CharactersViewModel()
    
    var body: some View {
        NavigationStack {
            VStack{
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorDescription = viewModel.errorDescription {
                    Text(errorDescription)
                } else if viewModel.characters.isEmpty {
                    Text("Character is Empty")
                } else {
                    
                    List(viewModel.characters) { character in
                        
                        if character.id % 2 == 0 {
                            
                            HStack(alignment: .top, spacing: 16) {
                                
                                ImageView(imageURL: character.image)
                                
                                Spacer()
                                    .frame(width:20)
                                
                                DescriptionView(character: character)
                            }
                            .listRowSeparator(.hidden)
                            
                        } else {
                            
                            HStack(alignment: .center, spacing: 16) {
                                DescriptionView(character: character)
                                
                                Spacer()
                                    .frame(width:20)
                                
                                ImageView(imageURL: character.image)
                            }
                            .listRowSeparator(.hidden)
                            
                        }
                        
                    }
                    .listStyle(.plain)
                    
                    
                    
                }
            }
            .navigationTitle("Characters")
            .background(.accent)
            
            Text("Wubba Lubba Dub Dub!")
                .font(.callout)
                .fontWeight(.bold)
                .task {
                    await viewModel.fetchCharacters()
                }
        }
    }
}
#Preview {
    CharactersView()
}
