import Foundation
import SwiftUI

struct FishingRig: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: RigType
    var difficulty: Difficulty
    var description: String
    var bestFor: BestFor
    var diagramImageName: String?
    
    // User data
    var isFavorite: Bool = false
    var userRating: UserRating = .notTried
    var userNotes: String = ""
    var dateModified: Date = Date()
    
    init(id: UUID = UUID(), name: String, type: RigType, difficulty: Difficulty, 
         description: String, bestFor: BestFor, diagramImageName: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.difficulty = difficulty
        self.description = description
        self.bestFor = bestFor
        self.diagramImageName = diagramImageName
    }
}

enum RigType: String, Codable, CaseIterable {
    case ice = "Ice"
    case float = "Float"
    case feeder = "Feeder"
    case spinning = "Spinning"
    
    var icon: String {
        switch self {
        case .ice: return "snow"
        case .float: return "circle.circle"
        case .feeder: return "square.grid.2x2"
        case .spinning: return "arrow.clockwise.circle"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return AppColors.success
        case .medium: return AppColors.accent
        case .hard: return AppColors.failure
        }
    }
}

enum UserRating: String, Codable, CaseIterable {
    case works = "Works"
    case doesntWork = "Doesn't Work"
    case notTried = "Not Tried"
    
    var icon: String {
        switch self {
        case .works: return "checkmark.circle.fill"
        case .doesntWork: return "xmark.circle.fill"
        case .notTried: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .works: return AppColors.success
        case .doesntWork: return AppColors.failure
        case .notTried: return AppColors.secondaryText
        }
    }
}

struct BestFor: Codable {
    var species: [String]
    var season: [Season]
    var depthRange: String
    
    enum Season: String, Codable, CaseIterable {
        case spring = "Spring"
        case summer = "Summer"
        case fall = "Fall"
        case winter = "Winter"
        
        var icon: String {
            switch self {
            case .spring: return "leaf"
            case .summer: return "sun.max"
            case .fall: return "wind"
            case .winter: return "snowflake"
            }
        }
    }
}

// Sample data
extension FishingRig {
    static let sampleRigs: [FishingRig] = [
        FishingRig(
            name: "Carolina Rig",
            type: .spinning,
            difficulty: .easy,
            description: "A versatile rig with a sliding sinker above a swivel, allowing the bait to move freely. Perfect for covering large areas and feeling subtle bites.",
            bestFor: BestFor(
                species: ["Bass", "Walleye", "Pike"],
                season: [.spring, .summer, .fall],
                depthRange: "5-20 feet"
            )
        ),
        FishingRig(
            name: "Texas Rig",
            type: .spinning,
            difficulty: .easy,
            description: "Weedless setup with the hook embedded in soft plastic bait. Ideal for fishing in heavy cover without snagging.",
            bestFor: BestFor(
                species: ["Bass", "Pike"],
                season: [.spring, .summer, .fall],
                depthRange: "2-15 feet"
            )
        ),
        FishingRig(
            name: "Drop Shot",
            type: .spinning,
            difficulty: .medium,
            description: "Hook tied above the weight, allowing bait to hover off the bottom. Excellent for finesse fishing and clear water conditions.",
            bestFor: BestFor(
                species: ["Bass", "Perch", "Trout"],
                season: [.spring, .summer, .fall, .winter],
                depthRange: "10-40 feet"
            )
        ),
        FishingRig(
            name: "Slip Bobber Rig",
            type: .float,
            difficulty: .easy,
            description: "Adjustable float rig allowing precise depth control. Great for suspended fish and varying water depths.",
            bestFor: BestFor(
                species: ["Crappie", "Bluegill", "Walleye"],
                season: [.spring, .summer, .fall],
                depthRange: "5-30 feet"
            )
        ),
        FishingRig(
            name: "Tip-Up Rig",
            type: .ice,
            difficulty: .easy,
            description: "Ice fishing setup with flag indicator for strikes. Allows fishing multiple holes simultaneously.",
            bestFor: BestFor(
                species: ["Pike", "Walleye", "Trout"],
                season: [.winter],
                depthRange: "10-40 feet"
            )
        ),
        FishingRig(
            name: "Method Feeder",
            type: .feeder,
            difficulty: .medium,
            description: "Cage feeder packed with groundbait, hook buried in the mix. Attracts fish to the hookbait effectively.",
            bestFor: BestFor(
                species: ["Carp", "Bream", "Tench"],
                season: [.spring, .summer, .fall],
                depthRange: "3-15 feet"
            )
        ),
        FishingRig(
            name: "Running Ledger",
            type: .feeder,
            difficulty: .easy,
            description: "Simple sliding weight rig allowing fish to take line without feeling resistance. Versatile for various conditions.",
            bestFor: BestFor(
                species: ["Catfish", "Carp", "Bream"],
                season: [.spring, .summer, .fall],
                depthRange: "5-25 feet"
            )
        ),
        FishingRig(
            name: "Chod Rig",
            type: .feeder,
            difficulty: .hard,
            description: "Stiff hooklink rig that sits on top of weed and debris. Highly effective in challenging bottom conditions.",
            bestFor: BestFor(
                species: ["Carp"],
                season: [.spring, .summer, .fall],
                depthRange: "5-20 feet"
            )
        ),
        FishingRig(
            name: "Ned Rig",
            type: .spinning,
            difficulty: .easy,
            description: "Minimalist finesse rig using a small mushroom-head jig and soft plastic stick bait. Deadly on pressured fish.",
            bestFor: BestFor(
                species: ["Bass", "Walleye"],
                season: [.spring, .summer, .fall, .winter],
                depthRange: "5-30 feet"
            )
        ),
        FishingRig(
            name: "Wacky Rig",
            type: .spinning,
            difficulty: .easy,
            description: "Hook through the middle of a soft plastic worm, creating unique action. Simple yet incredibly effective.",
            bestFor: BestFor(
                species: ["Bass"],
                season: [.spring, .summer, .fall],
                depthRange: "3-15 feet"
            )
        ),
        FishingRig(
            name: "Jig Head Rig",
            type: .ice,
            difficulty: .easy,
            description: "Weighted jig head with soft plastic or live bait. Versatile for ice fishing in various depths.",
            bestFor: BestFor(
                species: ["Perch", "Crappie", "Walleye"],
                season: [.winter],
                depthRange: "5-25 feet"
            )
        ),
        FishingRig(
            name: "Quick-Strike Rig",
            type: .ice,
            difficulty: .medium,
            description: "Dual-hook setup for live bait, allowing quick hooksets on aggressive predators.",
            bestFor: BestFor(
                species: ["Pike", "Musky"],
                season: [.winter],
                depthRange: "10-30 feet"
            )
        ),
        FishingRig(
            name: "Hair Rig",
            type: .feeder,
            difficulty: .medium,
            description: "Bait presented on a hair beside the hook, reducing fish awareness. Revolutionary carp fishing technique.",
            bestFor: BestFor(
                species: ["Carp", "Tench"],
                season: [.spring, .summer, .fall],
                depthRange: "3-20 feet"
            )
        ),
        FishingRig(
            name: "Popper Rig",
            type: .float,
            difficulty: .easy,
            description: "Surface lure creating noise and splash to attract aggressive fish. Exciting topwater action.",
            bestFor: BestFor(
                species: ["Bass", "Pike"],
                season: [.summer, .fall],
                depthRange: "Surface"
            )
        ),
        FishingRig(
            name: "Spreader Bar",
            type: .spinning,
            difficulty: .hard,
            description: "Multiple lures on wire arms creating a school of baitfish illusion. Effective for offshore trolling.",
            bestFor: BestFor(
                species: ["Tuna", "Marlin", "Wahoo"],
                season: [.spring, .summer, .fall],
                depthRange: "20-100 feet"
            )
        ),
        FishingRig(
            name: "Paternoster Rig",
            type: .float,
            difficulty: .medium,
            description: "Weight at the bottom with hook on a dropper above. Keeps bait off the bottom in current.",
            bestFor: BestFor(
                species: ["Flounder", "Cod", "Snapper"],
                season: [.spring, .summer, .fall, .winter],
                depthRange: "10-60 feet"
            )
        ),
        FishingRig(
            name: "Alabama Rig",
            type: .spinning,
            difficulty: .hard,
            description: "Umbrella rig with multiple wire arms and swimbaits. Mimics a school of baitfish.",
            bestFor: BestFor(
                species: ["Bass", "Striper"],
                season: [.fall, .winter, .spring],
                depthRange: "10-30 feet"
            )
        ),
        FishingRig(
            name: "Balloon Rig",
            type: .float,
            difficulty: .medium,
            description: "Uses a balloon as a float for long-distance drifting. Ideal for presenting live bait to surface feeders.",
            bestFor: BestFor(
                species: ["Sailfish", "Tuna", "Mahi"],
                season: [.spring, .summer, .fall],
                depthRange: "Surface-20 feet"
            )
        ),
        FishingRig(
            name: "Downrigger Setup",
            type: .spinning,
            difficulty: .hard,
            description: "Trolling rig using a weighted cable to reach precise depths. Professional trolling technique.",
            bestFor: BestFor(
                species: ["Salmon", "Trout", "Walleye"],
                season: [.spring, .summer, .fall],
                depthRange: "20-100 feet"
            )
        ),
        FishingRig(
            name: "Jigging Spoon",
            type: .ice,
            difficulty: .medium,
            description: "Vertical jigging with metal spoon lure. Aggressive action triggers reaction strikes.",
            bestFor: BestFor(
                species: ["Walleye", "Pike", "Lake Trout"],
                season: [.winter],
                depthRange: "15-50 feet"
            )
        )
    ]
}
