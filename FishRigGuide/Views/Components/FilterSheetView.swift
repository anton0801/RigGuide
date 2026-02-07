import SwiftUI

struct FilterSheetView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Rig Type
                        FilterSection(title: "Rig Type") {
                            FlowLayout(spacing: 10) {
                                ForEach(RigType.allCases, id: \.self) { type in
                                    SelectableChip(
                                        title: type.rawValue,
                                        isSelected: rigViewModel.selectedTypes.contains(type)
                                    ) {
                                        if rigViewModel.selectedTypes.contains(type) {
                                            rigViewModel.selectedTypes.remove(type)
                                        } else {
                                            rigViewModel.selectedTypes.insert(type)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Season
                        FilterSection(title: "Season") {
                            FlowLayout(spacing: 10) {
                                ForEach(BestFor.Season.allCases, id: \.self) { season in
                                    SelectableChip(
                                        title: season.rawValue,
                                        isSelected: rigViewModel.selectedSeasons.contains(season)
                                    ) {
                                        if rigViewModel.selectedSeasons.contains(season) {
                                            rigViewModel.selectedSeasons.remove(season)
                                        } else {
                                            rigViewModel.selectedSeasons.insert(season)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Difficulty
                        FilterSection(title: "Difficulty") {
                            FlowLayout(spacing: 10) {
                                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                    SelectableChip(
                                        title: difficulty.rawValue,
                                        isSelected: rigViewModel.selectedDifficulties.contains(difficulty),
                                        color: difficulty.color
                                    ) {
                                        if rigViewModel.selectedDifficulties.contains(difficulty) {
                                            rigViewModel.selectedDifficulties.remove(difficulty)
                                        } else {
                                            rigViewModel.selectedDifficulties.insert(difficulty)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        rigViewModel.clearAllFilters()
                    }
                    .foregroundColor(AppColors.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            content
        }
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = AppColors.accent
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : AppColors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? color : AppColors.card)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : AppColors.divider, lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
