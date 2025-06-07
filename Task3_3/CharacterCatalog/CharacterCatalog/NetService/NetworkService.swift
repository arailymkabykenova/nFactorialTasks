//
//  NetworkService.swift
//  CharacterCatalog
//
//  Created by Арайлым Кабыкенова on 06.06.2025.
//
import Foundation

class NetworkService {
    private let BASE_URL="https://rickandmortyapi.com/api"
    private let decoder=JSONDecoder()
    func get<Response:Decodable>(relativePath:String)async throws->Response {
        guard
            let url=URL(string: BASE_URL+relativePath)
        else{
            throw URLError(.badURL)
        }
        
        //var request=URLRequest(url: url)
        //request.httpMethod="GET"
        
        //let (data,_)=try await URLSession.shared.data(for: request)
        let(data,_)=try await URLSession.shared.data(from: url)
        let response=try decoder.decode(Response.self,from:data)
        //let response=try JSONDecoder().decode(Response.self, from: data)
        return response
        
    }
}
