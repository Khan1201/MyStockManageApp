import Foundation

struct MarketSentimentItem: Identifiable, Equatable {
    let id: String
    let headline: String
    let sourceName: String
    let publishedAtText: String
    let signal: MarketSentimentSignal
}
