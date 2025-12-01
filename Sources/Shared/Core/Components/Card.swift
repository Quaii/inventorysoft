import SwiftUI

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
        // Just a simple container
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            Card {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Glass Card")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("This is a glassmorphism card component.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .frame(width: 300, height: 150)
        }
    }
}
