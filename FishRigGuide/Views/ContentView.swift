import SwiftUI

struct ContentView: View {
    @StateObject private var rigViewModel = RigViewModel()
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView(isActive: $showSplash)
            } else if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(rigViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var rigViewModel: RigViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                RigsLibraryView()
                    .tag(0)
                
                MyRigsView()
                    .tag(1)
                
                CompareRigsView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "list.bullet.rectangle", title: "Rigs", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(icon: "star.fill", title: "My Rigs", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(icon: "arrow.left.arrow.right", title: "Compare", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarButton(icon: "gearshape.fill", title: "Settings", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .frame(height: 60)
        .background(AppColors.card)
        .overlay(
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppColors.accent : AppColors.secondaryText)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.accent : AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
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
