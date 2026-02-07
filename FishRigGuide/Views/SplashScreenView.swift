import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0.0
    @State private var lineProgress: CGFloat = 0.0
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    // Animated fishing line
                    FishingLineShape(progress: lineProgress)
                        .stroke(AppColors.accent, lineWidth: 2)
                        .frame(width: 80, height: 100)
                    
                    // Hook icon
                    Image(systemName: "figure.fishing")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(AppColors.accent)
                        .overlay(
                            Circle()
                                .stroke(AppColors.accent.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)
                        )
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                Text("FishRig Guide")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate in sequence
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.2)) {
                scale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
                lineProgress = 1.0
            }
            
            // Transition to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}

struct FishingLineShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let endY = rect.maxY * progress
        
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: endY))
        
        return path
    }
}
