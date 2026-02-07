import SwiftUI

struct RigsLibraryView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Rigs")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showFilterSheet = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 24))
                                .foregroundColor(hasActiveFilters ? AppColors.accent : AppColors.secondaryText)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Search bar
                    SearchBar(text: $rigViewModel.searchText)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                    
                    // Active filters chips
                    if hasActiveFilters {
                        ActiveFiltersView()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                    }
                    
                    // Rigs list
                    if rigViewModel.filteredRigs.isEmpty {
                        EmptyStateView(
                            icon: "figure.fishing",
                            title: "No rigs found",
                            message: "Try adjusting your filters"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(rigViewModel.filteredRigs) { rig in
                                    NavigationLink(destination: RigDetailView(rig: rig)) {
                                        RigCardView(rig: rig)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView()
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        !rigViewModel.selectedTypes.isEmpty ||
        !rigViewModel.selectedSeasons.isEmpty ||
        !rigViewModel.selectedDifficulties.isEmpty
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.secondaryText)
            
            TextField("Search rigs...", text: $text)
                .foregroundColor(.white)
                .accentColor(AppColors.accent)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(AppColors.card)
        .cornerRadius(12)
    }
}

struct ActiveFiltersView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(rigViewModel.selectedTypes), id: \.self) { type in
                    FilterChip(title: type.rawValue, color: AppColors.accent) {
                        rigViewModel.selectedTypes.remove(type)
                    }
                }
                
                ForEach(Array(rigViewModel.selectedSeasons), id: \.self) { season in
                    FilterChip(title: season.rawValue, color: AppColors.accent) {
                        rigViewModel.selectedSeasons.remove(season)
                    }
                }
                
                ForEach(Array(rigViewModel.selectedDifficulties), id: \.self) { difficulty in
                    FilterChip(title: difficulty.rawValue, color: difficulty.color) {
                        rigViewModel.selectedDifficulties.remove(difficulty)
                    }
                }
                
                Button(action: {
                    rigViewModel.clearAllFilters()
                }) {
                    Text("Clear All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.failure)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.failure.opacity(0.2))
                        .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.3))
        .cornerRadius(16)
    }
}

struct RigCardView: View {
    let rig: FishingRig
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Type icon
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: rig.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.accent)
            }
            
            // Rig info
            VStack(alignment: .leading, spacing: 6) {
                Text(rig.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Text(rig.type.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Circle()
                        .fill(AppColors.secondaryText)
                        .frame(width: 3, height: 3)
                    
                    Text(rig.difficulty.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(rig.difficulty.color)
                }
            }
            
            Spacer()
            
            // Status icons
            VStack(spacing: 4) {
                if rig.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.accent)
                        .font(.system(size: 18))
                }
                
                Image(systemName: rig.userRating.icon)
                    .foregroundColor(rig.userRating.color)
                    .font(.system(size: 18))
            }
        }
        .padding(15)
        .background(AppColors.card)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}
