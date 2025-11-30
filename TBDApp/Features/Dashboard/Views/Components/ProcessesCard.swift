import SwiftUI

struct ProcessesCard: View {
    let processes: [ProcessInfo]
    let onViewAll: () -> Void
    let onToggleProcess: (ProcessInfo) -> Void

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack {
                    Text("Processes")
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Button(action: onViewAll) {
                        Text("View All")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                // Content
                if processes.isEmpty {
                    // Empty State
                    VStack(spacing: theme.spacing.s) {
                        Spacer()

                        Image(systemName: "gear.badge.questionmark")
                            .font(.system(size: 32))
                            .foregroundColor(theme.colors.textSecondary)

                        Text("No processes configured yet")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textPrimary)

                        Text("Add a Telegram bot, RSS feed, or webhook.")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // Process List
                    VStack(spacing: theme.spacing.s) {
                        ForEach(processes) { process in
                            HStack(spacing: theme.spacing.m) {
                                // Icon
                                Image(systemName: process.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(theme.colors.accentPrimary)
                                    .frame(width: 32, height: 32)
                                    .background(theme.colors.surfaceElevated)
                                    .clipShape(Circle())

                                // Info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(process.name)
                                        .font(theme.typography.body)
                                        .foregroundColor(theme.colors.textPrimary)

                                    Text(process.status)
                                        .font(theme.typography.caption)
                                        .foregroundColor(theme.colors.textSecondary)
                                }

                                Spacer()

                                // Toggle Button
                                Button(action: { onToggleProcess(process) }) {
                                    Image(
                                        systemName: process.isRunning ? "pause.fill" : "play.fill"
                                    )
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(width: 28, height: 28)
                                    .background(theme.colors.surfaceElevated)
                                    .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(theme.spacing.m)
                            .background(theme.colors.surfaceSecondary)
                            .cornerRadius(theme.radii.small)
                        }
                    }
                }
            }
        }
        .frame(minHeight: 260)
    }
}

struct ProcessInfo: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let icon: String
    let isRunning: Bool
}
