//
//  MyProfile.swift
//  Task1
//
//  Created by Арайлым Кабыкенова on 03.06.2025.
//
import SwiftUI
struct MyProfile:View{
    @Environment(\.dismiss) var dismiss
    let images=["dog","older","me","pudel","young"]
    var body:some View{
       
           
            VStack(spacing:10){
                Image("camera")
                Text("your in LIFE2065")
                    .fontWeight(.bold)
                    .padding(.top,100)
                Text("Hello, World!It is my page where I share with my live in Geneva.I love the universe and animals.SO It is my dog Fluff.Here will be story of my youth and daily life.I'm 60 soon, and my friends and I will celebrate on a yacht and there will be a vlog.Stay with me:)")
                    .frame(width: 300,height: 200,alignment: .center)
                    
                Spacer()
                
                
            
                TabView{
                    ForEach(images,id:\.self){img in
                        Image(img)
                            .resizable()
                            .frame(width: 300, height: 300)
                            .cornerRadius(10)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                    
                .frame(width: 450, height: 400)
                
                
                Button("Home"){
                    dismiss()
                }
                .foregroundColor(Color(red:246/255,green:122/255,blue:144/255))
                .fontWeight(.bold)
                .padding(.bottom,60)
        }
    }
}

#Preview{
   MyProfile()
}
