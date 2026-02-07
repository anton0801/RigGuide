import SwiftUI


struct CompareRigsView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var selectedRigs: [FishingRig] = []
    @State private var showRigPicker = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Compare")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                
                if selectedRigs.isEmpty {
                    EmptyStateView(
                        icon: "arrow.left.arrow.right",
                        title: "Compare Rigs",
                        message: "Select 2-3 rigs to compare"
                    )
                    
                    Button(action: {
                        showRigPicker = true
                    }) {
                        Text("Select Rigs")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.accent)
                            .cornerRadius(25)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Selected rigs
                            ForEach(selectedRigs) { rig in
                                SelectedRigCard(rig: rig) {
                                    selectedRigs.removeAll { $0.id == rig.id }
                                }
                            }
                            
                            // Add more button
                            if selectedRigs.count < 3 {
                                Button(action: {
                                    showRigPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Another Rig")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.accent)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.card)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            
                            // Comparison table
                            if selectedRigs.count >= 2 {
                                ComparisonTable(rigs: selectedRigs)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .sheet(isPresented: $showRigPicker) {
            RigPickerView(selectedRigs: $selectedRigs, maxSelection: 3)
        }
    }
}

struct SelectedRigCard: View {
    let rig: FishingRig
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: rig.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rig.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(rig.type.rawValue + " • " + rig.difficulty.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.secondaryText)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(15)
        .background(AppColors.card)
        .cornerRadius(12)
    }
}

struct ComparisonTable: View {
    let rigs: [FishingRig]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Comparison")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 15)
            
            VStack(spacing: 1) {
                ComparisonRow(title: "Type", values: rigs.map { $0.type.rawValue })
                ComparisonRow(title: "Difficulty", values: rigs.map { $0.difficulty.rawValue })
                ComparisonRow(title: "Species", values: rigs.map { $0.bestFor.species.joined(separator: ", ") })
                ComparisonRow(title: "Season", values: rigs.map { $0.bestFor.season.map { $0.rawValue }.joined(separator: ", ") })
                ComparisonRow(title: "Depth", values: rigs.map { $0.bestFor.depthRange })
                ComparisonRow(title: "Rating", values: rigs.map { $0.userRating.rawValue })
            }
            .background(AppColors.card)
            .cornerRadius(12)
        }
    }
}

struct ComparisonRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.accent)
                .frame(width: 100, alignment: .leading)
                .padding(12)
            
            ForEach(0..<values.count, id: \.self) { index in
                Text(values[index])
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(AppColors.background)
            }
        }
        .background(AppColors.divider)
    }
}

struct RigPickerView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @Binding var selectedRigs: [FishingRig]
    let maxSelection: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(rigViewModel.allRigs) { rig in
                            Button(action: {
                                toggleSelection(rig: rig)
                            }) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.accent.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: rig.type.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(rig.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(rig.type.rawValue)
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    if isSelected(rig: rig) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.success)
                                    }
                                }
                                .padding(15)
                                .background(isSelected(rig: rig) ? AppColors.success.opacity(0.1) : AppColors.card)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(selectedRigs.count >= maxSelection && !isSelected(rig: rig))
                            .opacity((selectedRigs.count >= maxSelection && !isSelected(rig: rig)) ? 0.5 : 1.0)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Select Rigs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }
    
    private func isSelected(rig: FishingRig) -> Bool {
        selectedRigs.contains { $0.id == rig.id }
    }
    
    private func toggleSelection(rig: FishingRig) {
        if let index = selectedRigs.firstIndex(where: { $0.id == rig.id }) {
            selectedRigs.remove(at: index)
        } else if selectedRigs.count < maxSelection {
            selectedRigs.append(rig)
        }
    }
}
