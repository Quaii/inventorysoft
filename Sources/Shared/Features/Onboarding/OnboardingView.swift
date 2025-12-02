import SwiftUI

struct OnboardingView: View {
    @State private var selectedPlan: String? = "Collaboration"
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    let plans = [
        PlanOption(
            id: "Collaboration",
            title: "Collaboration",
            subtitle: "Treated as partnership",
            icon: "person.2.fill"
        ),
        PlanOption(
            id: "Paid Plan",
            title: "Paid Plan",
            subtitle: "Budget based, average $600",
            icon: "briefcase.fill"
        ),
        PlanOption(
            id: "Unpaid Plan",
            title: "Unpaid Plan",
            subtitle: "Based on mutual benefits",
            icon: "star.fill"
        ),
    ]

    var body: some View {
        ZStack {
            // Background
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Capsule()
                            .fill(
                                index == 1 ? Color.blue : Color.gray.opacity(0.3)
                            )
                            .frame(width: 40, height: 4)
                    }
                }
                .padding(.top, 40)

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)

                    Text("Contract")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white)
                        .cornerRadius(4)
                        .offset(y: 10)
                        .rotationEffect(.degrees(-5))
                }
                .padding(.top, 20)

                // Title
                VStack(spacing: 12) {
                    Text("Choose offer type")
                        .font(.largeTitle)
                        .foregroundColor(.primary)

                    Text("What type of collaboration do\nyou have in mind?")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Options
                VStack(spacing: 16) {
                    ForEach(plans) { plan in
                        Button(action: {
                            withAnimation {
                                selectedPlan = plan.id
                            }
                        }) {
                            HStack {
                                Image(systemName: plan.icon)
                                    .font(.title2)
                                    .foregroundColor(selectedPlan == plan.id ? .white : .primary)
                                    .frame(width: 40)

                                VStack(alignment: .leading) {
                                    Text(plan.title)
                                        .font(.headline)
                                        .foregroundColor(
                                            selectedPlan == plan.id ? .white : .primary)
                                    Text(plan.subtitle)
                                        .font(.caption)
                                        .foregroundColor(
                                            selectedPlan == plan.id
                                                ? .white.opacity(0.8) : .secondary)
                                }
                                Spacer()
                                if selectedPlan == plan.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedPlan == plan.id
                                            ? Color.blue : Color(nsColor: .controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedPlan == plan.id
                                            ? Color.blue : Color.secondary.opacity(0.2),
                                        lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 500)

                Spacer()

                // Footer Buttons
                HStack {
                    Button(action: {
                        // Back action
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: {
                        // Complete onboarding
                        appEnvironment.completeOnboarding()
                    }) {
                        HStack {
                            Text("Skip")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct PlanOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
