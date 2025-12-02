import SwiftUI

struct MetricWidget: View {
    let title: String
    let value: String
    let icon: String
    let trend: String?
    let trendIcon: String?
    let trendColor: Color?

    @Environment(\.theme) var theme

    init(
        title: String,
        value: String,
        icon: String,
        trend: String? = nil,
        trendIcon: String? = nil,
        trendColor: Color? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.trend = trend
        self.trendIcon = trendIcon
        self.trendColor = trendColor
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left: Icon
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.1))  // surface3
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)  // accent.default
            }
            .padding(.trailing, 16)

            // Right: Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(value)
                    .font(.title)  // .title.bold
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if let trend = trend {
                    HStack(spacing: 4) {
                        if let trendIcon = trendIcon {
                            Image(systemName: trendIcon)
                                .font(.caption.bold())
                        }
                        Text(trend)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(trendColor ?? .secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 260, height: 120)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(16)
    }
}
