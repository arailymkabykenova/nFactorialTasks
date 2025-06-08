import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var nickname = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Log in")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.second)
            
            TextField("Nickname", text: $nickname)
                .autocapitalization(.none)
                .font(.caption)
                .foregroundColor(Color.second)
            
            SecureField("Password", text: $password)
                .font(.caption)
                .foregroundColor(Color.second)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Login") {
                if !viewModel.login(nick: nickname, password: password) {
                    errorMessage = "Wrong nickname or password"
                }
            }
            .buttonStyle(.bordered)
            .background(Color.second)
            .cornerRadius(8)
            
            
            
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                
                NavigationLink("Register now") {
                    RegistrateView()
                }
                .foregroundColor(.second)
            }
            .font(.footnote)
            
        }
        
        .padding()
        .textFieldStyle(.roundedBorder)
        .background(Image("logBack"))
        
    }
}
#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
