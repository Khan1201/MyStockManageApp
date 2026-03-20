import Foundation

protocol StocksRemoteDataSource {
    func fetchStocksOverview() async throws -> StocksOverviewDTO
    func fetchStockInsights(for stock: StockDTO) async throws -> StockInsightsDTO
    func fetchAnalystForecasts(for stock: StockDTO) async throws -> AnalystForecastsContentDTO
    func fetchMarketSentiment(for stock: StockDTO) async throws -> [SentimentSectionDTO]
    func fetchEarningsRevenue(for stock: StockDTO) async throws -> [EarningsYearRecordDTO]
}
