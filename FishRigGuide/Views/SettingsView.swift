import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var showResetAlert = false
    @State private var showExportSheet = false
    @State private var exportedData = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tips & Safety
                        NavigationLink(destination: TipsAndSafetyView()) {
                            SettingsRow(icon: "lightbulb.fill", title: "Tips & Safety", color: AppColors.accent)
                        }
                        
                        // Export & Backup
                        Button(action: {
                            exportedData = rigViewModel.exportData()
                            showExportSheet = true
                        }) {
                            SettingsRow(icon: "square.and.arrow.up", title: "Export Data", color: AppColors.success)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Reset ratings
                        Button(action: {
                            showResetAlert = true
                        }) {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Reset User Ratings", color: AppColors.failure)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // About
                        NavigationLink(destination: AboutView()) {
                            SettingsRow(icon: "info.circle", title: "About", color: AppColors.secondaryText)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Ratings?"),
                message: Text("This will reset all user ratings and notes. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    resetAllData()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(items: [exportedData])
        }
    }
    
    private func resetAllData() {
        for i in 0..<rigViewModel.allRigs.count {
            rigViewModel.allRigs[i].userRating = .notTried
            rigViewModel.allRigs[i].userNotes = ""
            rigViewModel.allRigs[i].isFavorite = false
        }
        rigViewModel.saveRigs()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(15)
        .background(AppColors.card)
        .cornerRadius(12)
    }
}

struct TipsAndSafetyView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TipSection(
                        icon: "link",
                        title: "Knot Tips",
                        tips: [
                            "Always wet your line before tightening knots",
                            "Practice knots at home before heading out",
                            "Trim tag ends close to the knot",
                            "Test knot strength before fishing"
                        ]
                    )
                    
                    TipSection(
                        icon: "exclamationmark.triangle",
                        title: "Safety Notes",
                        tips: [
                            "Always wear a life jacket when fishing from a boat",
                            "Tell someone where you're fishing",
                            "Check weather conditions before heading out",
                            "Handle hooks and lures with care"
                        ]
                    )
                    
                    TipSection(
                        icon: "wrench.and.screwdriver",
                        title: "Gear Compatibility",
                        tips: [
                            "Match line weight to rod rating",
                            "Use appropriate hook size for target species",
                            "Check leader material compatibility",
                            "Adjust drag settings for different rigs"
                        ]
                    )
                }
                .padding(20)
            }
        }
        .navigationTitle("Tips & Safety")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TipSection: View {
    let icon: String
    let title: String
    let tips: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.accent)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)
                    
                    Text(tip)
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(AppColors.card)
        .cornerRadius(15)
    }
}

// AboutView.swift
struct AboutView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "figure.fishing")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.accent)
                
                Text("FishRig Guide")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Version 1.0.0")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.secondaryText)
                
                VStack(spacing: 15) {
                    Text("Your comprehensive fishing rig catalog with personal notes and effectiveness tracking.")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("© 2025 FishRig Guide")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// DiagramFullScreenView.swift
struct DiagramFullScreenView: View {
    let rigName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.card)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("Diagram for \(rigName)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("Pinch to zoom")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText.opacity(0.7))
                    }
                }
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                            withAnimation(.spring()) {
                                if scale < 1.0 {
                                    scale = 1.0
                                    lastScale = 1.0
                                } else if scale > 3.0 {
                                    scale = 3.0
                                    lastScale = 3.0
                                }
                            }
                        }
                )
                .padding(20)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(20)
                
                Spacer()
            }
        }
    }
}

// ShareSheet for exporting
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
