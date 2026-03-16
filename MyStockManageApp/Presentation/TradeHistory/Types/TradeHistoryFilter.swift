import SwiftUI

enum TradeHistoryFilter: String, CaseIterable, Identifiable {
    case all
    case buy
    case sell

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .all:
            return "All"
        case .buy:
            return "Buy"
        case .sell:
            return "Sell"
        }
    }
}
