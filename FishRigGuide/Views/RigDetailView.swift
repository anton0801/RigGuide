import SwiftUI

struct RigDetailView: View {
    let rig: FishingRig
    @EnvironmentObject var rigViewModel: RigViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showDiagram = false
    @State private var editingNotes = false
    @State private var notesText = ""
    @State private var showRatingPicker = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CustomNavigationBar(title: rig.name, onBack: {
                        presentationMode.wrappedValue.dismiss()
                    })
                    
                    HeaderSection()
                    
                    // Diagram section
                    DiagramSection()
                    
                    // Description
                    SectionContainer(title: "Description") {
                        Text(rig.description)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.secondaryText)
                            .lineSpacing(4)
                    }
                    
                    // Best For section
                    BestForSection()
                    
                    // User Rating
                    RatingSection()
                    
                    // User Notes
                    NotesSection()
                }
                .padding(20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
//        .overlay(
//            ,
//            alignment: .top
//        )
        .onAppear {
            notesText = rig.userNotes
        }
    }
    
    @ViewBuilder
    private func HeaderSection() -> some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: rig.type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(rig.type.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                HStack(spacing: 8) {
                    Text(rig.difficulty.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(rig.difficulty.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(rig.difficulty.color.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    rigViewModel.toggleFavorite(rig: rig)
                }
            }) {
                Image(systemName: rig.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 28))
                    .foregroundColor(rig.isFavorite ? AppColors.accent : AppColors.secondaryText)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(AppColors.card)
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private func DiagramSection() -> some View {
        SectionContainer(title: "Diagram") {
            Button(action: {
                showDiagram = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.background)
                        .frame(height: 200)
                    
                    VStack(spacing: 10) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("Tap to view diagram")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .sheet(isPresented: $showDiagram) {
            DiagramFullScreenView(rigName: rig.name)
        }
    }
    
    @ViewBuilder
    private func BestForSection() -> some View {
        SectionContainer(title: "Best For") {
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "fish", title: "Species", value: rig.bestFor.species.joined(separator: ", "))
                
                InfoRow(icon: "calendar", title: "Season", value: rig.bestFor.season.map { $0.rawValue }.joined(separator: ", "))
                
                InfoRow(icon: "arrow.down.to.line", title: "Depth", value: rig.bestFor.depthRange)
            }
        }
    }
    
    @ViewBuilder
    private func RatingSection() -> some View {
        SectionContainer(title: "Your Rating") {
            HStack(spacing: 15) {
                ForEach(UserRating.allCases, id: \.self) { rating in
                    RatingButton(
                        rating: rating,
                        isSelected: rig.userRating == rating
                    ) {
                        withAnimation(.spring()) {
                            rigViewModel.updateRating(rig: rig, rating: rating)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func NotesSection() -> some View {
        SectionContainer(title: "Personal Notes") {
            VStack(alignment: .leading, spacing: 10) {
                TextEditor(text: $notesText)
                    .frame(minHeight: 120)
                    .foregroundColor(.white)
                    .accentColor(AppColors.accent)
                    .padding(10)
                    .background(AppColors.background)
                    .cornerRadius(10)
                
                if notesText != rig.userNotes {
                    Button(action: {
                        rigViewModel.updateNotes(rig: rig, notes: notesText)
                        hideKeyboard()
                    }) {
                        Text("Save Notes")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(AppColors.accent)
                            .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                if !rig.userNotes.isEmpty {
                    Text("Last edited: \(rig.dateModified, formatter: dateFormatter)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            content
        }
        .padding(20)
        .background(AppColors.card)
        .cornerRadius(15)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.accent)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct RatingButton: View {
    let rating: UserRating
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: rating.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? rating.color : AppColors.secondaryText)
                
                Text(rating.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? rating.color : AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isSelected ? rating.color.opacity(0.2) : AppColors.background)
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
