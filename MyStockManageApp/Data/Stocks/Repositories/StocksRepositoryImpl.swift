import Foundation

final class StocksRepositoryImpl: StocksRepository {
    private let localDataSource: any StocksLocalDataSource
    private let remoteDataSource: any StocksRemoteDataSource

    init(
        localDataSource: any StocksLocalDataSource,
        remoteDataSource: any StocksRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func fetchStocksOverview() async throws -> StocksOverview {
        if let localOverview = try await localDataSource.fetchStocksOverview() {
            return try localOverview.toDomain()
        }

        let remoteOverview = try await remoteDataSource.fetchStocksOverview()
        try await localDataSource.saveStocksOverview(remoteOverview)
        return try remoteOverview.toDomain()
    }

    func fetchStockInsights(for stock: Stock) async throws -> StockInsights {
        if let localInsights = try await localDataSource.fetchStockInsights(symbol: stock.symbol) {
            return try localInsights.toDomain()
        }

        let remoteInsights = try await remoteDataSource.fetchStockInsights(for: StockDTO(stock: stock))
        try await localDataSource.saveStockInsights(remoteInsights, symbol: stock.symbol)
        return try remoteInsights.toDomain()
    }

    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsContent {
        if let localForecasts = try await localDataSource.fetchAnalystForecasts(symbol: stock.symbol) {
            return try localForecasts.toDomain()
        }

        let remoteForecasts = try await remoteDataSource.fetchAnalystForecasts(for: StockDTO(stock: stock))
        try await localDataSource.saveAnalystForecasts(remoteForecasts, symbol: stock.symbol)
        return try remoteForecasts.toDomain()
    }

    func fetchMarketSentiment(for stock: Stock) async throws -> [SentimentSection] {
        if let localSentiment = try await localDataSource.fetchMarketSentiment(symbol: stock.symbol) {
            return try localSentiment.map { try $0.toDomain() }
        }

        let remoteSentiment = try await remoteDataSource.fetchMarketSentiment(for: StockDTO(stock: stock))
        try await localDataSource.saveMarketSentiment(remoteSentiment, symbol: stock.symbol)
        return try remoteSentiment.map { try $0.toDomain() }
    }

    func fetchEarningsRevenue(for stock: Stock) async throws -> [EarningsYearRecord] {
        if let localRevenue = try await localDataSource.fetchEarningsRevenue(symbol: stock.symbol) {
            return try localRevenue.map { try $0.toDomain() }
        }

        let remoteRevenue = try await remoteDataSource.fetchEarningsRevenue(for: StockDTO(stock: stock))
        try await localDataSource.saveEarningsRevenue(remoteRevenue, symbol: stock.symbol)
        return try remoteRevenue.map { try $0.toDomain() }
    }
}
