import SwiftUI

struct RegistrateView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var nickname = ""
    @State private var password = ""
    
    
    @State private var registrationMessage = ""
    @State private var didRegister = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Image("task")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.5)
            
            
            
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.bottom, 20)
                    .foregroundColor(.white)
                
                TextField("First name", text: $firstName)
                    .font(.caption)
                    .foregroundColor(Color.second)
                    .frame(width:390)
                
                TextField("Last name", text: $lastName)
                    .font(.caption)
                    .foregroundColor(Color.second)
                    .frame(width:390)
                
                
                TextField("Nickname", text: $nickname)
                    .autocapitalization(.none)
                    .font(.caption)
                    .foregroundColor(Color.second)
                    .frame(width:390)
                
                
                
                SecureField("Password", text: $password)
                    .font(.caption)
                    .foregroundColor(Color.second)
                    .frame(width:390)
                
                
                Button(action: handleRegistration) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
                .frame(width:300)
                .buttonStyle(.bordered)
                .background(Color.second)
                .disabled(didRegister)
                .cornerRadius(8)
                
                
                
                if !registrationMessage.isEmpty {
                    Text(registrationMessage)
                        .font(.caption)
                        .foregroundColor(didRegister ? .second : .black)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            
            
            .padding(.top,350)
            .textFieldStyle(.roundedBorder)
            .navigationTitle("Registration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    private func handleRegistration() {
        guard !firstName.isEmpty, !lastName.isEmpty, !nickname.isEmpty, !password.isEmpty else {
            registrationMessage = "Please fill all fields."
            return
        }
        
        viewModel.registration(name: firstName, surname: lastName, nick: nickname, password: password)
        
        registrationMessage = "Registration successful!"
        didRegister = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        RegistrateView()
            .environmentObject(AuthViewModel())
    }
}
