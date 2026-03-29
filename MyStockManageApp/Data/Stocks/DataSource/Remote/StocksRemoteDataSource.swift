import Foundation

typealias PortfolioStockRemotePayload = (quote: FinnhubQuoteDTO, profile: FinnhubProfileDTO?)
typealias StockInsightsRemotePayload = (
    recommendations: [FinnhubRecommendationDTO],
    articles: [FinnhubNewsDTO],
    annualReports: [FinnhubFinancialReportDTO],
    quarterlyReports: [FinnhubFinancialReportDTO],
    earningsHistory: [FinnhubEarningsHistoryDTO],
    earningsCalendar: [FinnhubEarningsCalendarDTO]
)
typealias AnalystForecastsRemotePayload = (
    recommendations: [FinnhubRecommendationDTO],
    priceTarget: FinnhubPriceTargetDTO
)
typealias EarningsRevenueRemotePayload = (
    quarterlyReports: [FinnhubFinancialReportDTO],
    earningsHistory: [FinnhubEarningsHistoryDTO],
    earningsCalendar: [FinnhubEarningsCalendarDTO]
)

protocol StocksRemoteDataSource {
    func fetchStocksOverview() async throws -> [PortfolioStockRemotePayload]
    func fetchStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload
    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload
    func fetchMarketSentiment(for stock: Stock) async throws -> [FinnhubNewsDTO]
    func fetchEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload
}
