import SwiftUI

struct SelectionCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectionCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                SelectionCard(
                    iconName: "person.2.fill",
                    title: "Collaboration",
                    subtitle: "Treated as partnership",
                    isSelected: true,
                    action: {}
                )

                SelectionCard(
                    iconName: "briefcase.fill",
                    title: "Paid Plan",
                    subtitle: "Budget based, average $600",
                    isSelected: false,
                    action: {}
                )
            }
            .padding()
        }
    }
}
