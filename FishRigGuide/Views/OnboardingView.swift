import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Explore fishing rigs and setups",
            icon: "hook.circle",
            animationType: .lineDrawing
        ),
        OnboardingPage(
            title: "Save and rate rigs you use",
            icon: "star.circle.fill",
            animationType: .pulsingStar
        ),
        OnboardingPage(
            title: "Add your own notes and tweaks",
            icon: "note.text",
            animationType: .slideUp
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppColors.accent : AppColors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Action buttons
                HStack(spacing: 20) {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 50)
                                .background(AppColors.accent)
                                .cornerRadius(25)
                        }
                    } else {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.accent)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            showOnboarding = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let icon: String
    let animationType: AnimationType
    
    enum AnimationType {
        case lineDrawing, pulsingStar, slideUp
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animationProgress: CGFloat = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            ZStack {
                // Animated icon based on type
                switch page.animationType {
                case .lineDrawing:
                    HookLineAnimationView(progress: animationProgress)
                case .pulsingStar:
                    StarAnimationView(progress: animationProgress)
                case .slideUp:
                    NoteAnimationView(progress: animationProgress)
                }
            }
            .frame(height: 200)
            
            Text(page.title)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(textOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animationProgress = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
                textOpacity = 1.0
            }
        }
    }
}

struct HookLineAnimationView: View {
    let progress: CGFloat
    
    var body: some View {
        ZStack {
            // Animated line
            Path { path in
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 150 * progress))
            }
            .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            
            // Hook at bottom
            Image(systemName: "figure.fishing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(AppColors.accent)
                .offset(y: 50)
                .opacity(progress)
        }
    }
}

struct StarAnimationView: View {
    let progress: CGFloat
    
    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(AppColors.success)
            .scaleEffect(0.95 + (0.1 * sin(progress * .pi * 4)))
            .shadow(color: AppColors.success.opacity(0.5), radius: 20)
    }
}

struct NoteAnimationView: View {
    let progress: CGFloat
    
    var body: some View {
        Image(systemName: "note.text")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(AppColors.accent)
            .offset(y: 50 * (1 - progress))
            .opacity(progress)
    }
}
