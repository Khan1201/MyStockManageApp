import Foundation

enum AnalystRecommendation: String, Equatable, Sendable {
    case strongBuy
    case buy
    case hold
    case neutral
    case sell
    case strongSell
}

enum StockMarketSignal: String, Equatable, Sendable {
    case bullish
    case bearish
}

struct ForecastSummaryMetric: Identifiable, Equatable, Sendable {
    let id: String
    let recommendation: AnalystRecommendation
    let count: Int
}

struct SentimentSummaryMetric: Identifiable, Equatable, Sendable {
    let id: String
    let signal: StockMarketSignal
    let count: Int
}

enum EstimateStage: String, Equatable, Sendable {
    case actual
    case estimated
}

struct StockEstimateSnapshot: Identifiable, Equatable, Sendable {
    let id: String
    let year: Int
    let stage: EstimateStage
    let revenueText: String
    let revenueDeltaText: String?
    let revenueDeltaPercent: Double?
    let epsText: String
    let epsDeltaText: String?
    let epsDeltaPercent: Double?
}

struct StockInsights: Equatable, Sendable {
    let forecastSummary: [ForecastSummaryMetric]
    let sentimentSummary: [SentimentSummaryMetric]
    let earningsEstimates: [StockEstimateSnapshot]
}
