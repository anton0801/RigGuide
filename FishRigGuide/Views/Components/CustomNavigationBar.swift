import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.accent)
                    .frame(width: 40, height: 40)
                    .background(AppColors.card)
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Invisible placeholder for symmetry
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 10)
        .background(AppColors.background)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 70))
                .foregroundColor(AppColors.secondaryText)
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            isPulsing = true
        }
    }
}
