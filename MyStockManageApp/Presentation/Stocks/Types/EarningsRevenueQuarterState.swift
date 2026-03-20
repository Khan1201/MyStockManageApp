import SwiftUI

typealias EarningsRevenueQuarterState = EarningsQuarterState

extension EarningsRevenueQuarterState {
    var accentColor: Color? {
        switch self {
        case .beat:
            return Color(red: 0.12, green: 0.78, blue: 0.56)
        case .partialMiss:
            return Color(red: 0.98, green: 0.62, blue: 0.18)
        case .miss:
            return Color(red: 0.99, green: 0.29, blue: 0.39)
        case .projected:
            return nil
        }
    }

    var legendColor: Color {
        switch self {
        case .beat:
            return Color(red: 0.12, green: 0.78, blue: 0.56)
        case .partialMiss:
            return Color(red: 0.98, green: 0.62, blue: 0.18)
        case .miss:
            return Color(red: 0.99, green: 0.29, blue: 0.39)
        case .projected:
            return Color(red: 0.82, green: 0.87, blue: 0.93)
        }
    }

    var statusTitle: LocalizedStringResource? {
        switch self {
        case .beat:
            return "Beat"
        case .partialMiss:
            return "Missed"
        case .miss:
            return "Missed"
        case .projected:
            return nil
        }
    }
}
