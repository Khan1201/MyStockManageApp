import SwiftUI

struct MarketSentimentSection: Identifiable, Equatable {
    let id: String
    let title: LocalizedStringResource
    let items: [MarketSentimentItem]
}
