import SwiftUI

enum TradeHistoryTransactionType: String, Equatable {
    case buy
    case sell

    var badgeTitle: String {
        switch self {
        case .buy:
            return "B"
        case .sell:
            return "S"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .buy:
            return "Buy"
        case .sell:
            return "Sell"
        }
    }

    var tintColor: Color {
        switch self {
        case .buy:
            return Color(red: 0.15, green: 0.79, blue: 0.34)
        case .sell:
            return Color(red: 0.98, green: 0.27, blue: 0.29)
        }
    }
}
