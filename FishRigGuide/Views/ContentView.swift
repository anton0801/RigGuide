import SwiftUI

struct ContentView: View {
    @StateObject private var rigViewModel = RigViewModel()
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.opacity)
            } else {
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(rigViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: showOnboarding)
    }
}

// MARK: - Updated Main Tab View
struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var rigViewModel: RigViewModel
    @ObservedObject var streakManager = StreakManager.shared

    // Favorites count for badge
    private var favoritesCount: Int {
        rigViewModel.getFavorites().count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            ZStack {
                if selectedTab == 0 {
                    RigsLibraryView()
                        .transition(.opacity)
                } else if selectedTab == 1 {
                    MyRigsView()
                        .transition(.opacity)
                } else if selectedTab == 2 {
                    AnalyticsDashboardView()
                        .transition(.opacity)
                } else if selectedTab == 3 {
                    CompareRigsView()
                        .transition(.opacity)
                } else {
                    SettingsView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTab)

            // Custom Tab Bar
            CustomTabBar(
                selectedTab: $selectedTab,
                favoritesCount: favoritesCount,
                streakCount: streakManager.currentStreak
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Updated Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let favoritesCount: Int
    let streakCount: Int

    var body: some View {
        HStack(spacing: 0) {
            // Rigs
            TabBarButton(
                icon: "list.bullet.rectangle.portrait",
                title: "Rigs",
                isSelected: selectedTab == 0,
                badge: nil
            ) { selectedTab = 0 }

            // My Rigs — badge with count
            TabBarButton(
                icon: "star.fill",
                title: "My Rigs",
                isSelected: selectedTab == 1,
                badge: favoritesCount > 0 ? "\(favoritesCount)" : nil
            ) { selectedTab = 1 }

            // Analytics — streak flame badge
            TabBarButton(
                icon: "chart.bar.fill",
                title: "Stats",
                isSelected: selectedTab == 2,
                badge: nil,
                streakCount: streakCount
            ) { selectedTab = 2 }

            // Compare
            TabBarButton(
                icon: "arrow.left.arrow.right",
                title: "Compare",
                isSelected: selectedTab == 3,
                badge: nil
            ) { selectedTab = 3 }

            // Settings
            TabBarButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == 4,
                badge: nil
            ) { selectedTab = 4 }
        }
        .frame(height: 60)
        .padding(.bottom, 8)
        .background(
            Color(hex: "0A2236")
                .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: -4)
        )
        .overlay(
            Rectangle()
                .fill(Color(hex: "123A4F"))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Tab Bar Button with Badge
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let badge: String?
    var streakCount: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                action()
            }
        }) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? Color(hex: "4FC3F7") : Color(hex: "9CB6C9"))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .frame(width: 28, height: 28)

                    // Favorites badge (number)
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(hex: "4FC3F7"))
                            .clipShape(Capsule())
                            .offset(x: 10, y: -6)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Streak flame badge
                    if streakCount > 0 && badge == nil {
                        HStack(spacing: 1) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 7, weight: .bold))
                            Text("\(streakCount)")
                                .font(.system(size: 9, weight: .black))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(hex: StreakManager.shared.flameLevel.color))
                        .clipShape(Capsule())
                        .offset(x: 14, y: -6)
                    }
                }

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "4FC3F7") : Color(hex: "9CB6C9"))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
        }
        .buttonStyle(TabScaleButtonStyle())
    }
}

struct TabScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Streak New Record Banner
/// Drop this anywhere in the view hierarchy to show a toast when user beats their record
struct StreakRecordBanner: View {
    @ObservedObject var streakManager = StreakManager.shared
    @State private var show = false

    var body: some View {
        Group {
            if show {
                HStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Color(hex: "FFD700"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("New Record!")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                        Text("🔥 \(streakManager.currentStreak) day streak — personal best!")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9CB6C9"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "0F2F42"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "FFD700").opacity(0.4), lineWidth: 1.5)
                        )
                )
                .shadow(color: Color(hex: "FFD700").opacity(0.2), radius: 10)
                .padding(.horizontal, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            if streakManager.isNewStreakRecord {
                withAnimation(.spring()) { show = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation { show = false }
                    streakManager.isNewStreakRecord = false
                }
            }
        }
    }
}
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
