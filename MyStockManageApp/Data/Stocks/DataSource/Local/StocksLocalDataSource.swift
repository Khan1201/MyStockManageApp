import Foundation

protocol StocksLocalDataSource {
    func fetchStocksOverview() async throws -> StocksOverviewDTO?
    func saveStocksOverview(_ overview: StocksOverviewDTO) async throws
    func fetchStockInsights(symbol: String) async throws -> StockInsightsDTO?
    func saveStockInsights(_ insights: StockInsightsDTO, symbol: String) async throws
    func fetchAnalystForecasts(symbol: String) async throws -> AnalystForecastsContentDTO?
    func saveAnalystForecasts(_ forecasts: AnalystForecastsContentDTO, symbol: String) async throws
    func fetchMarketSentiment(symbol: String) async throws -> [SentimentSectionDTO]?
    func saveMarketSentiment(_ sections: [SentimentSectionDTO], symbol: String) async throws
    func fetchEarningsRevenue(symbol: String) async throws -> [EarningsYearRecordDTO]?
    func saveEarningsRevenue(_ sections: [EarningsYearRecordDTO], symbol: String) async throws
}
