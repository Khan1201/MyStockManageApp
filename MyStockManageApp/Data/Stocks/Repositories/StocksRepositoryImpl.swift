import Foundation

final class StocksRepositoryImpl: StocksRepository {
    private let remoteDataSource: any StocksRemoteDataSource
    private let transformer: StocksFinnhubTransformer

    init(
        remoteDataSource: any StocksRemoteDataSource,
        transformer: StocksFinnhubTransformer = StocksFinnhubTransformer()
    ) {
        self.remoteDataSource = remoteDataSource
        self.transformer = transformer
    }

    func fetchStocksOverview() async throws -> StocksOverview {
        let remoteOverview = try await remoteDataSource.fetchStocksOverview()
        return transformer.makeStocksOverview(from: remoteOverview)
    }

    func fetchStockInsights(for stock: Stock) async throws -> StockInsights {
        let remoteInsights = try await remoteDataSource.fetchStockInsights(for: stock)
        return transformer.makeStockInsights(
            recommendations: remoteInsights.recommendations,
            articles: remoteInsights.articles,
            annualReports: remoteInsights.annualReports,
            quarterlyReports: remoteInsights.quarterlyReports,
            earningsHistory: remoteInsights.earningsHistory,
            earningsCalendar: remoteInsights.earningsCalendar
        )
    }

    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsContent {
        let remoteForecasts = try await remoteDataSource.fetchAnalystForecasts(for: stock)
        return transformer.makeAnalystForecasts(
            recommendations: remoteForecasts.recommendations,
            priceTarget: remoteForecasts.priceTarget
        )
    }

    func fetchMarketSentiment(for stock: Stock) async throws -> [SentimentSection] {
        let remoteSentiment = try await remoteDataSource.fetchMarketSentiment(for: stock)
        return transformer.makeSentimentSections(from: remoteSentiment)
    }

    func fetchEarningsRevenue(for stock: Stock) async throws -> [EarningsYearRecord] {
        let remoteRevenue = try await remoteDataSource.fetchEarningsRevenue(for: stock)
        return transformer.makeEarningsYearRecords(
            quarterlyReports: remoteRevenue.quarterlyReports,
            earningsHistory: remoteRevenue.earningsHistory,
            earningsCalendar: remoteRevenue.earningsCalendar
        )
    }
}
