import SwiftUI
struct DescriptionView: View {
    let character: Characters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(character.name)
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Gender: \(character.gender.rawValue)")
            
            HStack {
                Text("Status: \(character.status.rawValue)")
                
                
                if character.status == .alive {
                    Image(systemName: "heart.circle.fill").foregroundColor(.green)
                } else if character.status == .dead {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                } else {
                    Image(systemName: "questionmark.circle.fill").foregroundColor(.gray)
                }
            }
            
            Text("Location: \(character.location.name)")
                .font(.subheadline)
                .foregroundColor(.set1)
                .background(.accent)
                .cornerRadius(8)
        }
    }
}
