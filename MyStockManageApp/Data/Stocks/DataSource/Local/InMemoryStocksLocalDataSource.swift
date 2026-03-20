import Foundation

actor InMemoryStocksLocalDataSource: StocksLocalDataSource {
    private var stocksOverview: StocksOverviewDTO?
    private var stockInsightsBySymbol: [String: StockInsightsDTO] = [:]
    private var analystForecastsBySymbol: [String: AnalystForecastsContentDTO] = [:]
    private var marketSentimentBySymbol: [String: [SentimentSectionDTO]] = [:]
    private var earningsRevenueBySymbol: [String: [EarningsYearRecordDTO]] = [:]

    func fetchStocksOverview() async throws -> StocksOverviewDTO? {
        stocksOverview
    }

    func saveStocksOverview(_ overview: StocksOverviewDTO) async throws {
        stocksOverview = overview
    }

    func fetchStockInsights(symbol: String) async throws -> StockInsightsDTO? {
        stockInsightsBySymbol[symbol]
    }

    func saveStockInsights(_ insights: StockInsightsDTO, symbol: String) async throws {
        stockInsightsBySymbol[symbol] = insights
    }

    func fetchAnalystForecasts(symbol: String) async throws -> AnalystForecastsContentDTO? {
        analystForecastsBySymbol[symbol]
    }

    func saveAnalystForecasts(_ forecasts: AnalystForecastsContentDTO, symbol: String) async throws {
        analystForecastsBySymbol[symbol] = forecasts
    }

    func fetchMarketSentiment(symbol: String) async throws -> [SentimentSectionDTO]? {
        marketSentimentBySymbol[symbol]
    }

    func saveMarketSentiment(_ sections: [SentimentSectionDTO], symbol: String) async throws {
        marketSentimentBySymbol[symbol] = sections
    }

    func fetchEarningsRevenue(symbol: String) async throws -> [EarningsYearRecordDTO]? {
        earningsRevenueBySymbol[symbol]
    }

    func saveEarningsRevenue(_ sections: [EarningsYearRecordDTO], symbol: String) async throws {
        earningsRevenueBySymbol[symbol] = sections
    }
}
