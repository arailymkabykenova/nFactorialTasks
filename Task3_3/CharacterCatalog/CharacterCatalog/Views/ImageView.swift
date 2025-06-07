import SwiftUI

struct ImageView: View {
    let imageURL: String
    
    var body: some View {
           AsyncImage(url: URL(string: imageURL)) { phase in
               if let image = phase.image {
                   image
                       .resizable()
                       .aspectRatio(contentMode: .fill)
               } else {
                   RoundedRectangle(cornerRadius: 12)
                       .foregroundColor(.gray.opacity(0.3))
               }
           }
           .frame(width: 120, height: 120)
           .clipShape(RoundedRectangle(cornerRadius: 12))
       }
   }
 
