import SwiftUI

enum StockChangeDirection: Equatable {
    case gain
    case loss

    var backgroundColor: Color {
        switch self {
        case .gain:
            return Color(red: 0.89, green: 0.98, blue: 0.92)
        case .loss:
            return Color(red: 1.0, green: 0.92, blue: 0.92)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .gain:
            return Color(red: 0.14, green: 0.72, blue: 0.32)
        case .loss:
            return Color(red: 0.89, green: 0.23, blue: 0.23)
        }
    }
}
