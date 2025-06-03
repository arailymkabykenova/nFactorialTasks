//
//  ContentView.swift
//  Task1
//
//  Created by Арайлым Кабыкенова on 03.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(
                    gradient:Gradient(colors:[Color.blue,Color.purple,Color.white]),
                    startPoint:.topLeading,
                    endPoint:.bottomLeading
                )
                .ignoresSafeArea()
                VStack(spacing:50){
                    VStack(){
                        
                        HStack(spacing:10){
                            Image(systemName:"person.circle")
                                .font(.system(size:30,weight:.bold))
                                .frame(alignment:.leading)
                            
                            
                            Text("Arailym Kabykenova")
                                .frame(width:150)
                                .font(.system(size:20,weight:.bold,design: .rounded))
                                .padding(.top,5)
                            Image("dog")
                                .resizable()
                                .scaledToFill()
                                .frame(width:60,height:60,alignment:.top)
                                .clipShape(Circle())
                                .padding(5)
                            
                        }
                        
                        
                        HStack(spacing:30){
                            
                            VStack{
                                Text("age:59")
                                
                                Image(systemName:"numbers.rectangle")
                                    .padding(2)
                                
                                
                            }
                            VStack{
                                Text("Switzerland")
                                Image(systemName:"mountain.2")
                                    .padding(2)
                                
                            }
                            VStack{
                                Text("123 456")
                                Image(systemName:"person.3.sequence.fill")
                                    .padding(2)
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(7)
                    .frame(width:350)
                    
                    
                    
                    .foregroundColor(.white)
                    
                    NavigationLink("My Profile",destination: MyProfile())
                        .buttonStyle(Buttons())
                    
                }
                
                
            }
        }
    }
    
    
}


#Preview {
    ContentView()
}

