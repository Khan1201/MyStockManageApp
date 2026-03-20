import Foundation

struct MarketSentimentSection: Identifiable, Equatable {
    let id: String
    let title: String
    let items: [MarketSentimentItem]
}
