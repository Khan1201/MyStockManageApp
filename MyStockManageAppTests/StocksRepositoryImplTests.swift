import XCTest
@testable import MyStockManageApp

final class StocksRepositoryImplTests: XCTestCase {
    func testFetchStocksOverviewLoadsRemoteDataWhenLocalCacheIsEmptyAndCachesIt() async throws {
        let localDataSource = InMemoryStocksLocalDataSource()
        let remoteOverview = StocksOverviewDTO(
            portfolio: [
                .init(symbol: "AAPL", companyName: "Apple Inc.", price: 189.43, changePercent: 1.24, brandRawValue: StockBrand.apple.rawValue)
            ],
            searchableStocks: [
                .init(symbol: "AMD", companyName: "Advanced Micro Devices, Inc.", brandRawValue: StockBrand.amd.rawValue)
            ]
        )
        let repository = StocksRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: StocksRemoteDataSourceStub(overview: remoteOverview)
        )

        let overview = try await repository.fetchStocksOverview()
        let cachedOverview = try await localDataSource.fetchStocksOverview()

        XCTAssertEqual(overview.portfolio.map(\.symbol), ["AAPL"])
        XCTAssertEqual(overview.searchableStocks.map(\.symbol), ["AMD"])
        XCTAssertEqual(cachedOverview, remoteOverview)
    }

    func testFetchStockInsightsLoadsRemoteDataWhenLocalCacheIsEmptyAndCachesIt() async throws {
        let localDataSource = InMemoryStocksLocalDataSource()
        let remoteInsights = StockInsightsDTO(
            forecastSummary: [.init(id: "buy", recommendationRawValue: AnalystRecommendation.buy.rawValue, count: 10)],
            sentimentSummary: [.init(id: "bullish", signalRawValue: StockMarketSignal.bullish.rawValue, count: 3)],
            earningsEstimates: [.init(id: "2026_est", year: 2026, stageRawValue: EstimateStage.estimated.rawValue, revenueText: "$100.0B", revenueDeltaText: nil, revenueDeltaPercent: nil, epsText: "$3.50", epsDeltaText: nil, epsDeltaPercent: nil)]
        )
        let repository = StocksRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: StocksRemoteDataSourceStub(stockInsights: remoteInsights)
        )
        let stock = Stock(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15, brand: .tesla)

        let insights = try await repository.fetchStockInsights(for: stock)
        let cachedInsights = try await localDataSource.fetchStockInsights(symbol: "TSLA")

        XCTAssertEqual(insights.forecastSummary.first?.count, 10)
        XCTAssertEqual(insights.sentimentSummary.first?.count, 3)
        XCTAssertEqual(cachedInsights, remoteInsights)
    }
}

private struct StocksRemoteDataSourceStub: StocksRemoteDataSource {
    var overview: StocksOverviewDTO = StocksOverviewDTO(portfolio: [], searchableStocks: [])
    var stockInsights: StockInsightsDTO = StockInsightsDTO(forecastSummary: [], sentimentSummary: [], earningsEstimates: [])
    var analystForecasts: AnalystForecastsContentDTO = AnalystForecastsContentDTO(
        overview: .init(averageTarget: 0, consensusRawValue: AnalystRecommendation.neutral.rawValue, analystsCount: 0),
        forecasts: []
    )
    var marketSentiment: [SentimentSectionDTO] = []
    var earningsRevenue: [EarningsYearRecordDTO] = []

    func fetchStocksOverview() async throws -> StocksOverviewDTO {
        overview
    }

    func fetchStockInsights(for _: StockDTO) async throws -> StockInsightsDTO {
        stockInsights
    }

    func fetchAnalystForecasts(for _: StockDTO) async throws -> AnalystForecastsContentDTO {
        analystForecasts
    }

    func fetchMarketSentiment(for _: StockDTO) async throws -> [SentimentSectionDTO] {
        marketSentiment
    }

    func fetchEarningsRevenue(for _: StockDTO) async throws -> [EarningsYearRecordDTO] {
        earningsRevenue
    }
}
