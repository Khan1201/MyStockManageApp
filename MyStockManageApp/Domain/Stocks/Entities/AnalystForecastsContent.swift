import Foundation

struct AnalystForecastOverview: Equatable, Sendable {
    let averageTarget: Double
    let consensus: AnalystRecommendation
    let analystsCount: Int
}

struct AnalystForecastRecord: Identifiable, Equatable, Sendable {
    let id: String
    let firmName: String
    let analystName: String
    let rating: AnalystRecommendation
    let score: Double
    let dateText: String
    let priceTarget: Double
}

struct AnalystForecastsContent: Equatable, Sendable {
    let overview: AnalystForecastOverview
    let forecasts: [AnalystForecastRecord]
}
