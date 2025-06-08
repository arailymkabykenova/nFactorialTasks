//
//  MyPage.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 07.06.2025.
//

import SwiftUI
struct MyPage:View{
    @EnvironmentObject var viewModel:AuthViewModel
    var body: some View{
        VStack{
            if let user = viewModel.user{
                Text("Welcome,to ToDo page,\(user.firstName)")
                    .font(.largeTitle)
                    .foregroundColor(Color.second)
            }
            Button("Log out"){
                viewModel.logOut()
            }
            .foregroundColor(Color.second)
        }
    }
}
