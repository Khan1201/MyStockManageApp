import Foundation

struct StockQuoteRemoteModel: Equatable, Sendable {
    let currentPrice: Double
    let changePercent: Double
}

struct StockProfileRemoteModel: Equatable, Sendable {
    let name: String?
    let logoURL: URL?

    init(
        name: String?,
        logoURL: URL? = nil
    ) {
        self.name = name
        self.logoURL = logoURL
    }

    var trimmedName: String? {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

struct StockRecommendationRemoteModel: Equatable, Sendable {
    let buy: Int
    let hold: Int
    let period: String
    let sell: Int
    let strongBuy: Int
    let strongSell: Int
}

struct StockPriceTargetRemoteModel: Equatable, Sendable {
    let targetHigh: Double?
    let targetLow: Double?
    let targetMean: Double?
    let targetMedian: Double?
}

struct SentimentArticleRemoteModel: Equatable, Sendable {
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let source: String
    let summary: String
}

struct EarningsHistoryRemoteModel: Equatable, Sendable {
    let actual: Double?
    let estimate: Double?
    let quarter: Int
    let year: Int
}

struct EarningsCalendarRemoteModel: Equatable, Sendable {
    let date: String
    let epsEstimate: Double?
    let quarter: Int
    let revenueEstimate: Double?
    let year: Int
}

struct FinancialReportRemoteModel: Equatable, Sendable {
    let filedDate: String
    let quarter: Int
    let revenueValue: Double?
    let dilutedEPSValue: Double?
    let year: Int
}

struct StockOverviewRemotePayload: Equatable, Sendable {
    let symbol: String
    let companyName: String
    let quote: StockQuoteRemoteModel
    let profile: StockProfileRemoteModel?
}

struct StocksOverviewRemotePayload: Equatable, Sendable {
    let portfolio: [StockOverviewRemotePayload]
}

struct StockSearchResultRemoteModel: Equatable, Sendable {
    let symbol: String
    let displaySymbol: String
    let description: String
    let type: String
}

struct StockInsightsRemotePayload: Equatable, Sendable {
    let recommendations: [StockRecommendationRemoteModel]
    let articles: [SentimentArticleRemoteModel]
    let annualReports: [FinancialReportRemoteModel]
    let quarterlyReports: [FinancialReportRemoteModel]
    let earningsHistory: [EarningsHistoryRemoteModel]
    let earningsCalendar: [EarningsCalendarRemoteModel]
}

struct AnalystForecastsRemotePayload: Equatable, Sendable {
    let recommendations: [StockRecommendationRemoteModel]
    let priceTarget: StockPriceTargetRemoteModel
}

struct EarningsRevenueRemotePayload: Equatable, Sendable {
    let quarterlyReports: [FinancialReportRemoteModel]
    let earningsHistory: [EarningsHistoryRemoteModel]
    let earningsCalendar: [EarningsCalendarRemoteModel]
}

protocol StocksRemoteDataSource {
    func fetchStocksOverview() async throws -> StocksOverviewRemotePayload
    func fetchStock(symbol: String) async throws -> StockOverviewRemotePayload
    func searchStocks(query: String) async throws -> [StockSearchResultRemoteModel]
    func fetchStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload
    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload
    func fetchMarketSentiment(for stock: Stock) async throws -> [SentimentArticleRemoteModel]
    func fetchEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload
}
