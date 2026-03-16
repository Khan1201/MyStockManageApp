import SwiftUI

struct StockSentimentItem: Identifiable {
    let id: String
    let title: LocalizedStringResource
    let count: Int
    let indicatorColor: Color
    let badgeForegroundColor: Color
    let badgeBackgroundColor: Color
}
