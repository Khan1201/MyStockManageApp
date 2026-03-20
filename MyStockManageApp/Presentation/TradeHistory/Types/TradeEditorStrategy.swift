import SwiftUI

typealias TradeEditorStrategy = TradeStrategy

extension TradeStrategy: Identifiable {
    var id: String { rawValue }
}

extension TradeStrategy {
    var title: LocalizedStringResource {
        switch self {
        case .longTerm:
            return "Long-term"
        case .themeBased:
            return "Theme-based"
        }
    }
}
