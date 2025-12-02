import SwiftUI

enum ToastType {
    case warning
    case success
    case error
    case info

    var color: Color {
        switch self {
        case .warning: return .orange
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }

    var icon: String {
        switch self {
        case .warning: return "exclamationmark.triangle"
        case .success: return "checkmark.circle"
        case .error: return "xmark.circle"
        case .info: return "info.circle"
        }
    }

    var title: String {
        switch self {
        case .warning: return "Warning"
        case .success: return "Success"
        case .error: return "Error"
        case .info: return "Info"
        }
    }
}

struct NotificationToast: View {
    let type: ToastType
    let message: String
    let subMessage: String?

    var body: some View {
        HStack(spacing: 0) {
            // Colored Bar
            Rectangle()
                .fill(type.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(type.title):")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                if let subMessage = subMessage {
                    Text(subMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(
            Color.black.opacity(0.8)
        )

        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(type.color.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: 400)
    }
}

struct NotificationToast_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                NotificationToast(
                    type: .warning,
                    message: "This action cannot be undone.",
                    subMessage:
                        "Deleting a workspace will permanently remove all its associated data."
                )

                NotificationToast(
                    type: .success,
                    message: "Workspace deleted successfully.",
                    subMessage: "All associated data has been permanently removed."
                )

                NotificationToast(
                    type: .error,
                    message: "This action is irreversible.",
                    subMessage: "Proceed with caution."
                )

                NotificationToast(
                    type: .info,
                    message: "Workspace deletion scheduled.",
                    subMessage: "You can cancel this action from settings within 24 hours."
                )
            }
            .padding()
        }
    }
}
