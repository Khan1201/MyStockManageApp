import Foundation

protocol StocksRepository {
    func fetchStocksOverview() async throws -> StocksOverview
    func fetchStock(symbol: String) async throws -> Stock
    func searchStocks(query: String) async throws -> [StockSearchResult]
    func fetchStockInsights(for stock: Stock) async throws -> StockInsights
    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsContent
    func fetchMarketSentiment(for stock: Stock) async throws -> [SentimentSection]
    func fetchEarningsRevenue(for stock: Stock) async throws -> [EarningsYearRecord]
}
