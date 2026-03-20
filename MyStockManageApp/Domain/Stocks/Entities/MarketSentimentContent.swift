import Foundation

struct SentimentArticle: Identifiable, Equatable, Sendable {
    let id: String
    let headline: String
    let sourceName: String
    let publishedAtText: String
    let signal: StockMarketSignal
}

struct SentimentSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let items: [SentimentArticle]
}
