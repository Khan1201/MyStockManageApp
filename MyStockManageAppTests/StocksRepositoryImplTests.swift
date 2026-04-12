import XCTest
@testable import MyStockManageApp

final class StocksRepositoryImplTests: XCTestCase {
    func testFetchStocksOverviewLoadsRemoteData() async throws {
        let remoteOverview: [PortfolioStockRemotePayload] = [
            .init(
                quote: .init(currentPrice: 189.43, changePercent: 1.24),
                profile: .init(
                    name: "Apple Inc.",
                    logoURL: URL(string: "https://example.com/aapl.png")
                )
            )
        ]
        let repository = StocksRepositoryImpl(remoteDataSource: StocksRemoteDataSourceStub(overview: remoteOverview))

        let overview = try await repository.fetchStocksOverview()

        XCTAssertEqual(overview.portfolio.map(\.symbol), ["AAPL"])
        XCTAssertEqual(overview.portfolio.first?.logoURL, URL(string: "https://example.com/aapl.png"))
        XCTAssertEqual(
            overview.searchableStocks.map(\.symbol),
            SupportedStockDescriptor.searchableDescriptors.map(\.symbol)
        )
    }

    func testFetchStockInsightsLoadsRemoteData() async throws {
        let remoteInsights = StockInsightsRemotePayload(
            recommendations: [
                .init(buy: 10, hold: 0, period: "2026-03-01", sell: 0, strongBuy: 0, strongSell: 0)
            ],
            articles: [
                .init(
                    datetime: 1_774_751_400,
                    headline: "Tesla shares surge after strong outlook",
                    id: 1,
                    source: "Bloomberg",
                    summary: "Bullish growth momentum improves expectations."
                )
            ],
            annualReports: [],
            quarterlyReports: [],
            earningsHistory: [],
            earningsCalendar: []
        )
        let repository = StocksRepositoryImpl(remoteDataSource: StocksRemoteDataSourceStub(stockInsights: remoteInsights))
        let stock = Stock(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15, brand: .tesla)

        let insights = try await repository.fetchStockInsights(for: stock)

        XCTAssertEqual(
            insights.forecastSummary.first(where: { $0.recommendation == .buy })?.count,
            10
        )
        XCTAssertEqual(insights.sentimentSummary.first?.count, 1)
    }

    func testFetchStocksOverviewRequestsRemoteDataOnEveryCall() async throws {
        let remoteDataSource = CountingStocksRemoteDataSource(
            overview: [
                .init(
                    quote: .init(currentPrice: 189.43, changePercent: 1.24),
                    profile: .init(name: "Apple Inc.")
                )
            ]
        )
        let repository = StocksRepositoryImpl(remoteDataSource: remoteDataSource)

        _ = try await repository.fetchStocksOverview()
        _ = try await repository.fetchStocksOverview()

        let overviewFetchCount = await remoteDataSource.overviewFetchCountSnapshot()
        XCTAssertEqual(overviewFetchCount, 2)
    }
}

private struct StocksRemoteDataSourceStub: StocksRemoteDataSource {
    var overview: [PortfolioStockRemotePayload] = []
    var stockInsights = StockInsightsRemotePayload(
        recommendations: [],
        articles: [],
        annualReports: [],
        quarterlyReports: [],
        earningsHistory: [],
        earningsCalendar: []
    )
    var analystForecasts = AnalystForecastsRemotePayload(
        recommendations: [],
        priceTarget: .init(targetHigh: nil, targetLow: nil, targetMean: nil, targetMedian: nil)
    )
    var marketSentiment: [SentimentArticleRemoteModel] = []
    var earningsRevenue = EarningsRevenueRemotePayload(
        quarterlyReports: [],
        earningsHistory: [],
        earningsCalendar: []
    )

    func fetchStocksOverview() async throws -> [PortfolioStockRemotePayload] {
        overview
    }

    func fetchStockInsights(for _: Stock) async throws -> StockInsightsRemotePayload {
        stockInsights
    }

    func fetchAnalystForecasts(for _: Stock) async throws -> AnalystForecastsRemotePayload {
        analystForecasts
    }

    func fetchMarketSentiment(for _: Stock) async throws -> [SentimentArticleRemoteModel] {
        marketSentiment
    }

    func fetchEarningsRevenue(for _: Stock) async throws -> EarningsRevenueRemotePayload {
        earningsRevenue
    }
}

private actor CountingStocksRemoteDataSource: StocksRemoteDataSource {
    private(set) var overviewFetchCount = 0
    let overview: [PortfolioStockRemotePayload]

    init(overview: [PortfolioStockRemotePayload]) {
        self.overview = overview
    }

    func fetchStocksOverview() async throws -> [PortfolioStockRemotePayload] {
        overviewFetchCount += 1
        return overview
    }

    func fetchStockInsights(for _: Stock) async throws -> StockInsightsRemotePayload {
        StockInsightsRemotePayload(
            recommendations: [],
            articles: [],
            annualReports: [],
            quarterlyReports: [],
            earningsHistory: [],
            earningsCalendar: []
        )
    }

    func fetchAnalystForecasts(for _: Stock) async throws -> AnalystForecastsRemotePayload {
        AnalystForecastsRemotePayload(
            recommendations: [],
            priceTarget: .init(targetHigh: nil, targetLow: nil, targetMean: nil, targetMedian: nil)
        )
    }

    func fetchMarketSentiment(for _: Stock) async throws -> [SentimentArticleRemoteModel] {
        []
    }

    func fetchEarningsRevenue(for _: Stock) async throws -> EarningsRevenueRemotePayload {
        EarningsRevenueRemotePayload(
            quarterlyReports: [],
            earningsHistory: [],
            earningsCalendar: []
        )
    }

    func overviewFetchCountSnapshot() -> Int {
        overviewFetchCount
    }
}
