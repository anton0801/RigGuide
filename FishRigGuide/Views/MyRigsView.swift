import SwiftUI


struct MyRigsView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("My Rigs")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 15)
                    
                    // Segment control
                    Picker("Category", selection: $selectedSegment) {
                        Text("Favorites").tag(0)
                        Text("Works").tag(1)
                        Text("Doesn't Work").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredRigs) { rig in
                                NavigationLink(destination: RigDetailView(rig: rig)) {
                                    RigCardView(rig: rig)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    if filteredRigs.isEmpty {
                        EmptyStateView(
                            icon: selectedSegment == 0 ? "star" : (selectedSegment == 1 ? "checkmark.circle" : "xmark.circle"),
                            title: emptyTitle,
                            message: emptyMessage
                        )
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var filteredRigs: [FishingRig] {
        switch selectedSegment {
        case 0:
            return rigViewModel.getFavorites()
        case 1:
            return rigViewModel.getRigsByRating(.works)
        case 2:
            return rigViewModel.getRigsByRating(.doesntWork)
        default:
            return []
        }
    }
    
    private var emptyTitle: String {
        switch selectedSegment {
        case 0: return "No favorites yet"
        case 1: return "No successful rigs"
        case 2: return "No unsuccessful rigs"
        default: return ""
        }
    }
    
    private var emptyMessage: String {
        switch selectedSegment {
        case 0: return "Add rigs to favorites from the library"
        case 1: return "Mark rigs that work well for you"
        case 2: return "Track rigs that didn't work out"
        default: return ""
        }
    }
}
