import SwiftUI

enum MarketSentimentFilter: CaseIterable, Identifiable {
    case all
    case bullish
    case bearish

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .all:
            return "All"
        case .bullish:
            return "Bullish"
        case .bearish:
            return "Bearish"
        }
    }

    func includes(_ signal: MarketSentimentSignal) -> Bool {
        switch self {
        case .all:
            return true
        case .bullish:
            return signal == .bullish
        case .bearish:
            return signal == .bearish
        }
    }
}
