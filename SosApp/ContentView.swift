//
//  ContentView.swift
//  SosApp
//
//  Created by Арайлым Кабыкенова on 02.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    NavigationLink("HOME",destination: HomeView())
                        .buttonStyle(Buttons())
                        Image(systemName: "house")
                    
                }
            
                HStack{
                    NavigationLink(destination:ProfileView()){
                        Text("MY PROFILE")
                            .padding(.horizontal,53)
                            .padding(.vertical)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        Image(systemName:"person.circle")
                            .foregroundColor(.black)
                            
                    }
                }
            }
            .padding()
        }
    }
}
    
    #Preview {
        ContentView()
    }
    
    struct HomeView:View{
        var body: some View{
            VStack{
                Button("Police",action:policeService)
                    .buttonStyle(Buttons())
                Button("Ambulance",action:ambulanceService)
                    .buttonStyle(Buttons())
                Button("Firefighters",action:fireService)
                    .buttonStyle(Buttons())
            }
            
        }
    }
    
    struct ProfileView:View{
        @Environment(\.dismiss) var dismiss
        var body:some View{
            VStack{
                
                Text("Welcome,Крош")
                    .profileStyle()
                    .bold()
                    .padding(.top,40)
                HStack{
                    Text("Personal information:")
                    Image("crosh")
                        .resizable()
                        .frame(width:100,height:100)
                        .clipShape(.circle)
                        .overlay(Circle())
                        .opacity(0.6)
                }.profileStyle()
                    
                Group {
                    Text("Name:Крош")
                    Text("Surname:Отсутствует")
                    Text("Age:18")
                    Text("Address:Сказочная долина 123")
                    Text("Phone Number:87079408897")
                    Text("Number of close person:87077356020")
                }
                .profileStyle()
                .padding(6)
                
                Spacer()
                Button("Back"){
                    dismiss()
                }
                .foregroundColor(.black)
                .padding(.bottom,40)
            }
        }
    }

extension View{
    func profileStyle()->some View{
        self.modifier(textStyle())
    }
}
func policeService(){
    print("Dangereous")
}
func ambulanceService(){
    print("Help")
}
func fireService(){
    print("Fire")
}
