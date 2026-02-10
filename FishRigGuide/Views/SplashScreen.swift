import SwiftUI
import Combine

struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
    var delay: Double
    var wobbleOffset: CGFloat
}

struct BubbleLayerView: View {
    @State private var bubbles: [Bubble] = []
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(bubbles) { bubble in
                    BubbleCellView(
                        bubble: bubble,
                        screenHeight: geo.size.height,
                        animating: animating
                    )
                }
            }
            .onAppear {
                bubbles = generateBubbles(in: geo.size)
                // Slight delay so views are ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animating = true
                }
            }
        }
        .clipped()
    }

    private func generateBubbles(in size: CGSize) -> [Bubble] {
        (0..<28).map { i in
            Bubble(
                x: CGFloat.random(in: 20...(size.width - 20)),
                size: CGFloat.random(in: 6...22),
                opacity: Double.random(in: 0.15...0.55),
                speed: Double.random(in: 3.5...8.0),
                delay: Double.random(in: 0...4.0),
                wobbleOffset: CGFloat.random(in: -12...12)
            )
        }
    }
}

// MARK: - Single Bubble Cell
struct BubbleCellView: View {
    let bubble: Bubble
    let screenHeight: CGFloat
    let animating: Bool

    @State private var yOffset: CGFloat = 0
    @State private var xWobble: CGFloat = 0
    @State private var appeared = false

    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "4FC3F7").opacity(bubble.opacity),
                        Color(hex: "6FE3C1").opacity(bubble.opacity * 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: bubble.size < 10 ? 1 : 1.5
            )
            .background(
                Circle()
                    .fill(Color(hex: "4FC3F7").opacity(bubble.opacity * 0.08))
            )
            .frame(width: bubble.size, height: bubble.size)
            .overlay(
                // Shine highlight on bubble
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: bubble.size * 0.3, height: bubble.size * 0.3)
                    .offset(x: -bubble.size * 0.15, y: -bubble.size * 0.15),
                alignment: .topLeading
            )
            .position(x: bubble.x + xWobble, y: screenHeight + bubble.size)
            .offset(y: yOffset)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                guard animating else { return }
                startBubbleAnimation()
            }
            .onChange(of: animating) { newVal in
                if newVal { startBubbleAnimation() }
            }
    }

    private func startBubbleAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + bubble.delay) {
            withAnimation(.easeIn(duration: 0.3)) {
                appeared = true
            }
            // Rise upward
            withAnimation(
                Animation.easeInOut(duration: bubble.speed)
                    .repeatForever(autoreverses: false)
            ) {
                yOffset = -(screenHeight + bubble.size * 2 + 40)
            }
            // Wobble side to side
            withAnimation(
                Animation.easeInOut(duration: bubble.speed * 0.4)
                    .repeatForever(autoreverses: true)
            ) {
                xWobble = bubble.wobbleOffset
            }
        }
    }
}

// MARK: - Fishing Line Shape
struct FishingLineShape: Shape {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * progress))
        return path
    }
}

// MARK: - Water Shimmer Background
struct WaterShimmerBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Deep base
            Color(hex: "071B27")

            // Animated gradient layer simulating light on water
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "071B27"), location: 0),
                    .init(color: Color(hex: "0A2236").opacity(0.9), location: 0.3 + phase * 0.1),
                    .init(color: Color(hex: "0F2F42").opacity(0.6), location: 0.6 + phase * 0.05),
                    .init(color: Color(hex: "071B27"), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.lighten)

            // Subtle radial glow in center
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4FC3F7").opacity(0.08 + phase * 0.04),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .blendMode(.screen)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }
}

// MARK: - Hook Circle Icon
struct HookCircleIcon: View {
    var scale: CGFloat
    var opacity: Double
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(Color(hex: "4FC3F7").opacity(glowPulse ? 0.25 : 0.10), lineWidth: 1.5)
                .frame(width: 130, height: 130)
                .scaleEffect(glowPulse ? 1.06 : 0.98)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

            // Mid ring
            Circle()
                .stroke(Color(hex: "4FC3F7").opacity(0.35), lineWidth: 1)
                .frame(width: 108, height: 108)

            // Inner filled circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "0F2F42"),
                            Color(hex: "0A2236")
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 90, height: 90)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "4FC3F7").opacity(0.6), lineWidth: 2)
                        .frame(width: 90, height: 90)
                )
                .shadow(color: Color(hex: "4FC3F7").opacity(0.4), radius: 15, x: 0, y: 0)

            // Hook icon
            Image(systemName: "figure.fishing")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
                .foregroundColor(Color(hex: "4FC3F7"))
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear { glowPulse = true }
    }
}


struct SplashScreenView: View {

    // Animation states
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var lineProgress: CGFloat = 0
    @State private var taglineOffset: CGFloat = 20
    
    @StateObject private var vm = AppRigViewModel()
    @State private var streams = Set<AnyCancellable>()
    
    private func setupStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { vm.receiveAttribution($0) }
            .store(in: &streams)

        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { vm.receiveDeeplink($0) }
            .store(in: &streams)
    }

    var body: some View {
        NavigationView {
            ZStack {
                WaterShimmerBackground()

                BubbleLayerView()
                    .ignoresSafeArea()

                VStack {
                    FishingLineShape(progress: lineProgress)
                        .stroke(
                            Color(hex: "9CB6C9").opacity(0.5),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                        )
                        .frame(width: 2, height: 80)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                .padding(.top, 60)

                VStack(spacing: 0) {
                    Spacer()

                    // Logo
                    HookCircleIcon(scale: logoScale, opacity: logoOpacity)
                        .padding(.bottom, 28)

                    // App name
                    VStack(spacing: 6) {
                        Text("Rig")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2)
                        +
                        Text(" Guide")
                            .font(.system(size: 38, weight: .light, design: .rounded))
                            .foregroundColor(Color(hex: "4FC3F7"))
                            .tracking(2)
                    }
                    .opacity(titleOpacity)
                    .padding(.bottom, 10)

                    // Tagline
                    Text("Your rig companion")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "9CB6C9"))
                        .tracking(1.5)
                        .opacity(subtitleOpacity)
                        .offset(y: taglineOffset)
                    
                    Text("Loading...")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "9CB6C9"))
                        .tracking(1.5)
                        .opacity(subtitleOpacity)
                        .offset(y: taglineOffset)

                    Spacer()

                    // Bottom indicator
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            Capsule()
                                .fill(Color(hex: "4FC3F7").opacity(subtitleOpacity > 0 ? (i == 1 ? 1 : 0.4) : 0))
                                .frame(width: i == 1 ? 20 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.5).delay(Double(i) * 0.1), value: subtitleOpacity)
                        }
                    }
                    .padding(.bottom, 50)
                }
                
                NavigationLink(
                    destination: RigWebView().navigationBarHidden(true),
                    isActive: $vm.goToWeb
                ) { EmptyView() }

                NavigationLink(
                    destination: ContentView().navigationBarBackButtonHidden(true),
                    isActive: $vm.goToMain
                ) { EmptyView() }
            }
            .onAppear {
                runAnimationSequence()
                setupStreams()
                vm.start()
            }
            .fullScreenCover(isPresented: $vm.showPermissionView) {
                RigPermissionView(vm: vm)
            }
            .fullScreenCover(isPresented: $vm.showOfflineView) {
                UnavailableView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }

    private func runAnimationSequence() {
        // 1. Line draws in
        withAnimation(.easeOut(duration: 0.7)) {
            lineProgress = 1.0
        }

        // 2. Logo appears with spring
        withAnimation(.spring(response: 0.65, dampingFraction: 0.62, blendDuration: 0).delay(0.4)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // 3. Title fades in
        withAnimation(.easeOut(duration: 0.6).delay(0.85)) {
            titleOpacity = 1.0
        }

        // 4. Subtitle slides up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(1.1)) {
            subtitleOpacity = 1.0
            taglineOffset = 0
        }
    }
}

struct RigPermissionView: View {
    @ObservedObject var vm: AppRigViewModel

    var body: some View {
        GeometryReader { g in
            ZStack {
                Color.black.ignoresSafeArea()

                Image("for_notifications")
                    .resizable().scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea().opacity(0.9)

                if g.size.width < g.size.height {
                    VStack(spacing: 12) {
                        Spacer()
                        labels
                        buttons
                    }.padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) { Spacer(); labels }
                        Spacer()
                        VStack { Spacer(); buttons }
                        Spacer()
                    }.padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private var labels: some View {
        VStack(spacing: 8) {
            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)

            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
        }
    }

    private var buttons: some View {
        VStack(spacing: 30) {
            Button {
                vm.allowPermission()
            } label: {
                Image("for_notifications_btn").resizable().frame(width: 300, height: 55)
            }
            Button { vm.deferPermission() } label: {
                Text("Skip").font(.headline).foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 60)
    }
}

struct UnavailableView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(geo.size.width > geo.size.height ? "inet_problem_2" : "inet_problem")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                Image("inet_problem_alert")
                    .resizable()
                    .frame(width: 300, height: 270)
            }
        }
        .ignoresSafeArea()
    }
}


#Preview {
    RigPermissionView(vm: AppRigViewModel())
}
