//
//  AuthViewModel.swift
//  MyApp
//
//  Created by Арайлым Кабыкенова on 04.06.2025.
//
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    
    private let registeredUserKey = "registeredUserKey"
    private let currentUserSessionKey = "currentUserSessionKey"
    
    init() {
        
        loadUserFromSession()
    }
    
    
    func loadUserFromSession() {
        
        guard let loggedInNickname = UserDefaults.standard.string(forKey: currentUserSessionKey) else {
            self.user = nil
            return
        }
        
        guard let userData = UserDefaults.standard.data(forKey: registeredUserKey),
              let registeredUser = try? JSONDecoder().decode(User.self, from: userData)
                
        else {
            self.user = nil
            return
        }
        
        
        if registeredUser.nickname == loggedInNickname {
            self.user = registeredUser
        } else {
            self.user = nil
        }
    }
    
    func registration(name: String, surname: String, nick: String, password: String) {
        let newUser = User(
            firstName: name,
            lastName: surname,
            nickname: nick,
            password: password,
            tasks: []
        )
        
        if let userData = try? JSONEncoder().encode(newUser) {
            UserDefaults.standard.set(userData, forKey: registeredUserKey)
        }
    }
    
    func login(nick: String, password: String) -> Bool {
        
        guard let userData = UserDefaults.standard.data(forKey: registeredUserKey),
              let registeredUser = try? JSONDecoder().decode(User.self, from: userData) else {
            return false
        }
        
        
        if registeredUser.nickname == nick && registeredUser.password == password {
            self.user = registeredUser
            
            UserDefaults.standard.set(nick, forKey: currentUserSessionKey)
            return true
        } else {
            return false
        }
    }
    
    func logOut() {
        
        UserDefaults.standard.removeObject(forKey: currentUserSessionKey)
        self.user = nil
    }
    
    
    func updateUserTasks(newTasks: [Task]) {
        guard var currentUser = self.user else{return }
        
        currentUser.tasks = newTasks
        self.user = currentUser
        
        
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: "registeredUserKey")
        }
    }
}
