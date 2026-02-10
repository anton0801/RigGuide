
import SwiftUI

struct StreakBadgeView: View {
    @ObservedObject var streakManager = StreakManager.shared
    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main tab icon content (passed externally)
            Color.clear

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(hex: "4FC3F7"))
                    .clipShape(Capsule())
                    .offset(x: 12, y: -6)
            }
        }
    }
}

// MARK: - Streak Flame Card
struct StreakFlameCard: View {
    @ObservedObject var streakManager = StreakManager.shared
    @State private var flameScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4

    private var flameColor: Color { Color(hex: streakManager.flameLevel.color) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "9CB6C9"))

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(streakManager.currentStreak)")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(streakManager.currentStreak == 1 ? "day" : "days")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "9CB6C9"))
                            .padding(.bottom, 8)
                    }

                    Text(streakManager.flameLevel.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(flameColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(flameColor.opacity(0.18))
                        .cornerRadius(8)
                }

                Spacer()

                // Animated flame icon
                ZStack {
                    Circle()
                        .fill(flameColor.opacity(glowOpacity))
                        .frame(width: 80, height: 80)
                        .blur(radius: 18)

                    Image(systemName: streakManager.flameLevel.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(flameColor)
                        .scaleEffect(flameScale)
                }
                .padding(.trailing, 8)
            }
            .padding(20)

            Divider()
                .background(Color(hex: "123A4F"))

            // Bottom: best streak + total days
            HStack {
                StatMiniItem(
                    icon: "trophy.fill",
                    label: "Best Streak",
                    value: "\(streakManager.longestStreak)d",
                    color: Color(hex: "FFB74D")
                )

                Divider()
                    .frame(height: 36)
                    .background(Color(hex: "123A4F"))

                StatMiniItem(
                    icon: "calendar",
                    label: "Total Days",
                    value: "\(streakManager.totalDaysUsed)",
                    color: Color(hex: "4FC3F7")
                )

                Divider()
                    .frame(height: 36)
                    .background(Color(hex: "123A4F"))

                StatMiniItem(
                    icon: "clock",
                    label: "Since",
                    value: sinceLabel,
                    color: Color(hex: "6FE3C1")
                )
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
        }
        .background(Color(hex: "0F2F42"))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(flameColor.opacity(0.25), lineWidth: 1.5)
        )
        .shadow(color: flameColor.opacity(0.15), radius: 12, x: 0, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                flameScale = 1.12
                glowOpacity = 0.7
            }
        }
    }

    private var sinceLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: streakManager.firstOpenDate)
    }
}

struct StatMiniItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "9CB6C9"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weekly Activity Bar Chart
struct WeeklyActivityView: View {
    @ObservedObject var streakManager = StreakManager.shared
    @State private var animated = false

    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last 7 Days")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    let active = streakManager.last7DaysActivity[i]
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                active
                                ? LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "6FE3C1"),
                                        Color(hex: "4FC3F7")
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "123A4F"),
                                        Color(hex: "123A4F")
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                height: animated ? (active ? CGFloat.random(in: 36...52) : 14) : 4
                            )
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.65)
                                .delay(Double(i) * 0.07),
                                value: animated
                            )
                            .overlay(
                                active
                                ? RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(hex: "6FE3C1").opacity(0.4), lineWidth: 1)
                                : nil
                            )

                        // Day label
                        Text(dayLabel(for: i))
                            .font(.system(size: 11, weight: active ? .semibold : .regular))
                            .foregroundColor(active ? Color(hex: "4FC3F7") : Color(hex: "9CB6C9"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 72)
        }
        .padding(20)
        .background(Color(hex: "0F2F42"))
        .cornerRadius(18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animated = true
            }
        }
    }

    private func dayLabel(for index: Int) -> String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let day = cal.date(byAdding: .day, value: -(6 - index), to: today) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: day).prefix(2))
    }
}

// MARK: - Rigs Statistics Card
struct RigsStatsCard: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var animated = false

    private var totalRigs: Int { rigViewModel.allRigs.count }
    private var favorites: Int { rigViewModel.getFavorites().count }
    private var works: Int { rigViewModel.getRigsByRating(.works).count }
    private var doesntWork: Int { rigViewModel.getRigsByRating(.doesntWork).count }
    private var notTried: Int { rigViewModel.getRigsByRating(.notTried).count }
    private var withNotes: Int { rigViewModel.allRigs.filter { !$0.userNotes.isEmpty }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rig Collection")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            // Progress bar: tried vs not
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Tried")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "9CB6C9"))
                    Spacer()
                    Text("\(works + doesntWork) / \(totalRigs)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "123A4F"))
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "6FE3C1"), Color(hex: "4FC3F7")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: animated && totalRigs > 0
                                    ? geo.size.width * CGFloat(works + doesntWork) / CGFloat(totalRigs)
                                    : 0,
                                height: 10
                            )
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: animated)
                    }
                }
                .frame(height: 10)
            }

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                RigStatCell(value: favorites, label: "Favorites", icon: "star.fill", color: Color(hex: "4FC3F7"))
                RigStatCell(value: works, label: "Works", icon: "checkmark.circle.fill", color: Color(hex: "6FE3C1"))
                RigStatCell(value: doesntWork, label: "Doesn't Work", icon: "xmark.circle.fill", color: Color(hex: "FF8A8A"))
                RigStatCell(value: notTried, label: "Not Tried", icon: "questionmark.circle", color: Color(hex: "9CB6C9"))
                RigStatCell(value: withNotes, label: "With Notes", icon: "note.text", color: Color(hex: "FFB74D"))
                RigStatCell(value: totalRigs, label: "Total Rigs", icon: "figure.fishing", color: Color(hex: "4FC3F7"))
            }
        }
        .padding(20)
        .background(Color(hex: "0F2F42"))
        .cornerRadius(18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animated = true
            }
        }
    }
}

struct RigStatCell: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text("\(value)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(appeared ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.15), value: appeared)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "9CB6C9"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "071B27").opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .onAppear { appeared = true }
    }
}

// MARK: - Difficulty Breakdown Donut
struct DifficultyBreakdownCard: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var selectedSegment: Difficulty? = nil
    @State private var animated = false

    private var easyCount: Int { rigViewModel.allRigs.filter { $0.difficulty == .easy }.count }
    private var mediumCount: Int { rigViewModel.allRigs.filter { $0.difficulty == .medium }.count }
    private var hardCount: Int { rigViewModel.allRigs.filter { $0.difficulty == .hard }.count }
    private var total: Int { rigViewModel.allRigs.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Difficulty Breakdown")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                // Simple bar representation
                VStack(spacing: 8) {
                    DifficultyBar(
                        label: "Easy",
                        count: easyCount,
                        total: total,
                        color: Color(hex: "6FE3C1"),
                        animated: animated
                    )
                    DifficultyBar(
                        label: "Medium",
                        count: mediumCount,
                        total: total,
                        color: Color(hex: "4FC3F7"),
                        animated: animated
                    )
                    DifficultyBar(
                        label: "Hard",
                        count: hardCount,
                        total: total,
                        color: Color(hex: "FF8A8A"),
                        animated: animated
                    )
                }
            }
        }
        .padding(20)
        .background(Color(hex: "0F2F42"))
        .cornerRadius(18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animated = true
            }
        }
    }
}

struct DifficultyBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let animated: Bool

    private var ratio: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(count) / CGFloat(total)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "9CB6C9"))
                .frame(width: 52, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hex: "123A4F"))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(color)
                        .frame(width: animated ? geo.size.width * ratio : 0, height: 10)
                        .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.15), value: animated)
                }
            }
            .frame(height: 10)

            Text("\(count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

// MARK: - Top Species Card
struct TopSpeciesCard: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var appeared = false

    private var speciesCounts: [(String, Int)] {
        var counts: [String: Int] = [:]
        for rig in rigViewModel.allRigs {
            for species in rig.bestFor.species {
                counts[species, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    private var maxCount: Int { speciesCounts.first?.1 ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Top Species")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "fish.fill")
                    .foregroundColor(Color(hex: "4FC3F7"))
            }

            ForEach(Array(speciesCounts.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 12) {
                    // Rank
                    Text("#\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(rankColor(index))
                        .frame(width: 28)

                    Text(item.0)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "123A4F"))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(rankColor(index))
                                .frame(
                                    width: appeared ? geo.size.width * CGFloat(item.1) / CGFloat(maxCount) : 0,
                                    height: 8
                                )
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.08),
                                    value: appeared
                                )
                        }
                    }
                    .frame(height: 8)

                    Text("\(item.1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "9CB6C9"))
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .background(Color(hex: "0F2F42"))
        .cornerRadius(18)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appeared = true
            }
        }
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color(hex: "FFD700")
        case 1: return Color(hex: "C0C0C0")
        case 2: return Color(hex: "CD7F32")
        default: return Color(hex: "4FC3F7")
        }
    }
}

// MARK: - Full Analytics Dashboard
struct AnalyticsDashboardView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @ObservedObject var streakManager = StreakManager.shared
    @State private var headerVisible = false

    var body: some View {
        ZStack {
            Color(hex: "071B27").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Analytics")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Your fishing journey")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "9CB6C9"))
                        }
                        Spacer()
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "4FC3F7"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 4)
                    .offset(y: headerVisible ? 0 : -20)
                    .opacity(headerVisible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: headerVisible)

                    // Streak card
                    StreakFlameCard()
                        .padding(.horizontal, 20)

                    // Weekly activity
                    WeeklyActivityView()
                        .padding(.horizontal, 20)

                    // Rig stats
                    RigsStatsCard()
                        .padding(.horizontal, 20)

                    // Difficulty breakdown
                    DifficultyBreakdownCard()
                        .padding(.horizontal, 20)

                    // Top species
                    TopSpeciesCard()
                        .padding(.horizontal, 20)

                    Spacer(minLength: 80)
                }
            }
        }
        .onAppear { headerVisible = true }
    }
}
