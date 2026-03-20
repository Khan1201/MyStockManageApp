import Foundation

struct ForecastSummaryMetricDTO: Equatable, Sendable {
    let id: String
    let recommendationRawValue: String
    let count: Int

    func toDomain() throws -> ForecastSummaryMetric {
        guard let recommendation = AnalystRecommendation(rawValue: recommendationRawValue) else {
            throw StocksDTOError.invalidRecommendation(recommendationRawValue)
        }

        return ForecastSummaryMetric(id: id, recommendation: recommendation, count: count)
    }
}

struct SentimentSummaryMetricDTO: Equatable, Sendable {
    let id: String
    let signalRawValue: String
    let count: Int

    func toDomain() throws -> SentimentSummaryMetric {
        guard let signal = StockMarketSignal(rawValue: signalRawValue) else {
            throw StocksDTOError.invalidSignal(signalRawValue)
        }

        return SentimentSummaryMetric(id: id, signal: signal, count: count)
    }
}

struct StockEstimateSnapshotDTO: Equatable, Sendable {
    let id: String
    let year: Int
    let stageRawValue: String
    let revenueText: String
    let revenueDeltaText: String?
    let revenueDeltaPercent: Double?
    let epsText: String
    let epsDeltaText: String?
    let epsDeltaPercent: Double?

    func toDomain() throws -> StockEstimateSnapshot {
        guard let stage = EstimateStage(rawValue: stageRawValue) else {
            throw StocksDTOError.invalidEstimateStage(stageRawValue)
        }

        return StockEstimateSnapshot(
            id: id,
            year: year,
            stage: stage,
            revenueText: revenueText,
            revenueDeltaText: revenueDeltaText,
            revenueDeltaPercent: revenueDeltaPercent,
            epsText: epsText,
            epsDeltaText: epsDeltaText,
            epsDeltaPercent: epsDeltaPercent
        )
    }
}

struct StockInsightsDTO: Equatable, Sendable {
    let forecastSummary: [ForecastSummaryMetricDTO]
    let sentimentSummary: [SentimentSummaryMetricDTO]
    let earningsEstimates: [StockEstimateSnapshotDTO]

    func toDomain() throws -> StockInsights {
        try StockInsights(
            forecastSummary: forecastSummary.map { try $0.toDomain() },
            sentimentSummary: sentimentSummary.map { try $0.toDomain() },
            earningsEstimates: earningsEstimates.map { try $0.toDomain() }
        )
    }
}

struct AnalystForecastOverviewDTO: Equatable, Sendable {
    let averageTarget: Double
    let consensusRawValue: String
    let analystsCount: Int

    func toDomain() throws -> AnalystForecastOverview {
        guard let consensus = AnalystRecommendation(rawValue: consensusRawValue) else {
            throw StocksDTOError.invalidRecommendation(consensusRawValue)
        }

        return AnalystForecastOverview(
            averageTarget: averageTarget,
            consensus: consensus,
            analystsCount: analystsCount
        )
    }
}

struct AnalystForecastRecordDTO: Equatable, Sendable {
    let id: String
    let firmName: String
    let analystName: String
    let ratingRawValue: String
    let score: Double
    let dateText: String
    let priceTarget: Double

    func toDomain() throws -> AnalystForecastRecord {
        guard let rating = AnalystRecommendation(rawValue: ratingRawValue) else {
            throw StocksDTOError.invalidRecommendation(ratingRawValue)
        }

        return AnalystForecastRecord(
            id: id,
            firmName: firmName,
            analystName: analystName,
            rating: rating,
            score: score,
            dateText: dateText,
            priceTarget: priceTarget
        )
    }
}

struct AnalystForecastsContentDTO: Equatable, Sendable {
    let overview: AnalystForecastOverviewDTO
    let forecasts: [AnalystForecastRecordDTO]

    func toDomain() throws -> AnalystForecastsContent {
        try AnalystForecastsContent(
            overview: overview.toDomain(),
            forecasts: forecasts.map { try $0.toDomain() }
        )
    }
}

struct SentimentArticleDTO: Equatable, Sendable {
    let id: String
    let headline: String
    let sourceName: String
    let publishedAtText: String
    let signalRawValue: String

    func toDomain() throws -> SentimentArticle {
        guard let signal = StockMarketSignal(rawValue: signalRawValue) else {
            throw StocksDTOError.invalidSignal(signalRawValue)
        }

        return SentimentArticle(
            id: id,
            headline: headline,
            sourceName: sourceName,
            publishedAtText: publishedAtText,
            signal: signal
        )
    }
}

struct SentimentSectionDTO: Equatable, Sendable {
    let id: String
    let title: String
    let items: [SentimentArticleDTO]

    func toDomain() throws -> SentimentSection {
        try SentimentSection(id: id, title: title, items: items.map { try $0.toDomain() })
    }
}

struct EarningsQuarterRecordDTO: Equatable, Sendable {
    let id: String
    let quarterTitle: String
    let trailingStatusText: String
    let stateRawValue: String
    let revenueValueText: String
    let revenueEstimateText: String?
    let revenuePerformancePercent: Double?
    let epsValueText: String
    let epsEstimateText: String?
    let epsPerformancePercent: Double?

    func toDomain() throws -> EarningsQuarterRecord {
        guard let state = Self.quarterState(from: stateRawValue) else {
            throw StocksDTOError.invalidQuarterState(stateRawValue)
        }

        return EarningsQuarterRecord(
            id: id,
            quarterTitle: quarterTitle,
            trailingStatusText: trailingStatusText,
            state: state,
            revenueValueText: revenueValueText,
            revenueEstimateText: revenueEstimateText,
            revenuePerformancePercent: revenuePerformancePercent,
            epsValueText: epsValueText,
            epsEstimateText: epsEstimateText,
            epsPerformancePercent: epsPerformancePercent
        )
    }

    private static func quarterState(from rawValue: String) -> EarningsQuarterState? {
        switch rawValue {
        case "beat":
            return .beat
        case "partialMiss":
            return .partialMiss
        case "miss":
            return .miss
        case "projected":
            return .projected
        default:
            return nil
        }
    }
}

struct EarningsYearRecordDTO: Equatable, Sendable {
    let year: Int
    let quarterItems: [EarningsQuarterRecordDTO]

    func toDomain() throws -> EarningsYearRecord {
        try EarningsYearRecord(year: year, quarterItems: quarterItems.map { try $0.toDomain() })
    }
}

enum StocksDTOError: Error {
    case invalidBrand(String)
    case invalidRecommendation(String)
    case invalidSignal(String)
    case invalidEstimateStage(String)
    case invalidQuarterState(String)
}
