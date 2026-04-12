import XCTest
@testable import MyStockManageApp

final class StocksRepositoryImplTests: XCTestCase {
    func testFetchStocksOverviewLoadsPortfolioRemoteData() async throws {
        let remoteOverview = StocksOverviewRemotePayload(
            portfolio: [
                .init(
                    symbol: "AAPL",
                    companyName: "Apple Inc.",
                    quote: .init(currentPrice: 189.43, changePercent: 1.24),
                    profile: .init(
                        name: "Apple Inc.",
                        logoURL: URL(string: "https://example.com/aapl.png")
                    )
                )
            ]
        )
        let repository = StocksRepositoryImpl(remoteDataSource: StocksRemoteDataSourceStub(overview: remoteOverview))

        let overview = try await repository.fetchStocksOverview()

        XCTAssertEqual(overview.portfolio.map(\.symbol), ["AAPL"])
        XCTAssertEqual(overview.portfolio.first?.logoURL, URL(string: "https://example.com/aapl.png"))
    }

    func testFetchStockLoadsSingleRemoteStock() async throws {
        let remoteStock = StockOverviewRemotePayload(
            symbol: "AMD",
            companyName: "AMD",
            quote: .init(currentPrice: 142.10, changePercent: -0.78),
            profile: .init(name: "Advanced Micro Devices, Inc.")
        )
        let repository = StocksRepositoryImpl(
            remoteDataSource: StocksRemoteDataSourceStub(stock: remoteStock)
        )

        let stock = try await repository.fetchStock(symbol: "AMD")

        XCTAssertEqual(stock.symbol, "AMD")
        XCTAssertEqual(stock.companyName, "Advanced Micro Devices, Inc.")
        XCTAssertEqual(stock.price, 142.10)
        XCTAssertEqual(stock.changePercent, -0.78)
    }

    func testSearchStocksMapsRemoteResults() async throws {
        let repository = StocksRepositoryImpl(
            remoteDataSource: StocksRemoteDataSourceStub(
                searchResults: [
                    .init(
                        symbol: "AAPL",
                        displaySymbol: "AAPL",
                        description: "Apple Inc.",
                        type: "Common Stock"
                    ),
                    .init(
                        symbol: "",
                        displaySymbol: "",
                        description: "Invalid",
                        type: "Common Stock"
                    )
                ]
            )
        )

        let results = try await repository.searchStocks(query: "apple")

        XCTAssertEqual(
            results,
            [
                StockSearchResult(
                    symbol: "AAPL",
                    displaySymbol: "AAPL",
                    companyName: "Apple Inc.",
                    type: "Common Stock"
                )
            ]
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
        let stock = Stock(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15)

        let insights = try await repository.fetchStockInsights(for: stock)

        XCTAssertEqual(
            insights.forecastSummary.first(where: { $0.recommendation == .buy })?.count,
            10
        )
        XCTAssertEqual(insights.sentimentSummary.first?.count, 1)
    }

    func testFetchStocksOverviewRequestsRemoteDataOnEveryCall() async throws {
        let remoteDataSource = CountingStocksRemoteDataSource(
            overview: StocksOverviewRemotePayload(
                portfolio: [
                    .init(
                        symbol: "AAPL",
                        companyName: "Apple Inc.",
                        quote: .init(currentPrice: 189.43, changePercent: 1.24),
                        profile: .init(name: "Apple Inc.")
                    )
                ]
            )
        )
        let repository = StocksRepositoryImpl(remoteDataSource: remoteDataSource)

        _ = try await repository.fetchStocksOverview()
        _ = try await repository.fetchStocksOverview()

        let overviewFetchCount = await remoteDataSource.overviewFetchCountSnapshot()
        XCTAssertEqual(overviewFetchCount, 2)
    }
}

private struct StocksRemoteDataSourceStub: StocksRemoteDataSource {
    var overview = StocksOverviewRemotePayload(portfolio: [])
    var stock = StockOverviewRemotePayload(
        symbol: "AAPL",
        companyName: "Apple Inc.",
        quote: .init(currentPrice: 189.43, changePercent: 1.24),
        profile: .init(name: "Apple Inc.")
    )
    var searchResults: [StockSearchResultRemoteModel] = []
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

    func fetchStocksOverview() async throws -> StocksOverviewRemotePayload {
        overview
    }

    func fetchStock(symbol _: String) async throws -> StockOverviewRemotePayload {
        stock
    }

    func searchStocks(query _: String) async throws -> [StockSearchResultRemoteModel] {
        searchResults
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
    let overview: StocksOverviewRemotePayload

    init(overview: StocksOverviewRemotePayload) {
        self.overview = overview
    }

    func fetchStocksOverview() async throws -> StocksOverviewRemotePayload {
        overviewFetchCount += 1
        return overview
    }

    func fetchStock(symbol: String) async throws -> StockOverviewRemotePayload {
        StockOverviewRemotePayload(
            symbol: symbol,
            companyName: symbol,
            quote: .init(currentPrice: 0, changePercent: 0),
            profile: nil
        )
    }

    func searchStocks(query _: String) async throws -> [StockSearchResultRemoteModel] {
        []
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
