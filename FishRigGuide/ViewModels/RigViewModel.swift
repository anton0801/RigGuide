import Foundation
import Combine

class RigViewModel: ObservableObject {
    @Published var allRigs: [FishingRig] = []
    @Published var filteredRigs: [FishingRig] = []
    @Published var searchText: String = ""
    @Published var selectedTypes: Set<RigType> = []
    @Published var selectedSeasons: Set<BestFor.Season> = []
    @Published var selectedDifficulties: Set<Difficulty> = []
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "savedRigs"
    
    init() {
        loadRigs()
        setupSearchAndFilters()
    }
    
    private func setupSearchAndFilters() {
        Publishers.CombineLatest4(
            $allRigs,
            $searchText,
            $selectedTypes,
            $selectedSeasons
        )
        .combineLatest($selectedDifficulties)
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] (combined, difficulties) in
            let (rigs, search, types, seasons) = combined
            self?.applyFilters(rigs: rigs, search: search, types: types, seasons: seasons, difficulties: difficulties)
        }
        .store(in: &cancellables)
    }
    
    private func applyFilters(rigs: [FishingRig], search: String, types: Set<RigType>, 
                              seasons: Set<BestFor.Season>, difficulties: Set<Difficulty>) {
        var result = rigs
        
        // Search filter
        if !search.isEmpty {
            result = result.filter { rig in
                rig.name.lowercased().contains(search.lowercased()) ||
                rig.description.lowercased().contains(search.lowercased())
            }
        }
        
        // Type filter
        if !types.isEmpty {
            result = result.filter { types.contains($0.type) }
        }
        
        // Season filter
        if !seasons.isEmpty {
            result = result.filter { rig in
                !Set(rig.bestFor.season).isDisjoint(with: seasons)
            }
        }
        
        // Difficulty filter
        if !difficulties.isEmpty {
            result = result.filter { difficulties.contains($0.difficulty) }
        }
        
        filteredRigs = result
    }
    
    func loadRigs() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FishingRig].self, from: data) {
            allRigs = decoded
        } else {
            allRigs = FishingRig.sampleRigs
            saveRigs()
        }
    }
    
    func saveRigs() {
        if let encoded = try? JSONEncoder().encode(allRigs) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func toggleFavorite(rig: FishingRig) {
        if let index = allRigs.firstIndex(where: { $0.id == rig.id }) {
            allRigs[index].isFavorite.toggle()
            allRigs[index].dateModified = Date()
            saveRigs()
        }
    }
    
    func updateRating(rig: FishingRig, rating: UserRating) {
        if let index = allRigs.firstIndex(where: { $0.id == rig.id }) {
            allRigs[index].userRating = rating
            allRigs[index].dateModified = Date()
            saveRigs()
        }
    }
    
    func updateNotes(rig: FishingRig, notes: String) {
        if let index = allRigs.firstIndex(where: { $0.id == rig.id }) {
            allRigs[index].userNotes = notes
            allRigs[index].dateModified = Date()
            saveRigs()
        }
    }
    
    func addCustomRig(_ rig: FishingRig) {
        allRigs.append(rig)
        saveRigs()
    }
    
    func deleteRig(_ rig: FishingRig) {
        allRigs.removeAll { $0.id == rig.id }
        saveRigs()
    }
    
    func getRigsByRating(_ rating: UserRating) -> [FishingRig] {
        allRigs.filter { $0.userRating == rating }
    }
    
    func getFavorites() -> [FishingRig] {
        allRigs.filter { $0.isFavorite }
    }
    
    func clearAllFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedSeasons.removeAll()
        selectedDifficulties.removeAll()
    }
    
    func exportData() -> String {
        var csv = "Name,Type,Difficulty,Rating,Notes,Favorite\n"
        for rig in allRigs {
            let notes = rig.userNotes.replacingOccurrences(of: "\n", with: " ")
            csv += "\(rig.name),\(rig.type.rawValue),\(rig.difficulty.rawValue),\(rig.userRating.rawValue),\"\(notes)\",\(rig.isFavorite)\n"
        }
        return csv
    }
}
