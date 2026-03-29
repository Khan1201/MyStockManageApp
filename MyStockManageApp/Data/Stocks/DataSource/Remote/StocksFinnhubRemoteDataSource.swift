import Foundation

struct StocksFinnhubRemoteDataSource: StocksRemoteDataSource {
    private let client: FinnhubClient

    init(
        session: any StocksHTTPSession = URLSession.shared,
        configuration: FinnhubConfiguration = .live(),
        calendar: Calendar = .autoupdatingCurrent,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.client = FinnhubClient(
            session: session,
            configuration: configuration,
            calendar: calendar,
            nowProvider: nowProvider
        )
    }

    func fetchStocksOverview() async throws -> [PortfolioStockRemotePayload] {
        try await fetchLiveStocksOverview()
    }

    func fetchStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload {
        try await fetchLiveStockInsights(for: stock)
    }

    func fetchAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload {
        try await fetchLiveAnalystForecasts(for: stock)
    }

    func fetchMarketSentiment(for stock: Stock) async throws -> [FinnhubNewsDTO] {
        try await fetchLiveMarketSentimentSections(for: stock)
    }

    func fetchEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        try await fetchLiveEarningsRevenue(for: stock)
    }
}

private extension StocksFinnhubRemoteDataSource {
    func fetchLiveStocksOverview() async throws -> [PortfolioStockRemotePayload] {
        let portfolio = try await withThrowingTaskGroup(of: IndexedPortfolioStockPayload.self) { group in
            for (index, descriptor) in StocksFinnhubTransformer.portfolioDescriptors.enumerated() {
                group.addTask {
                    let stock = try await fetchPortfolioStock(for: descriptor)
                    return IndexedPortfolioStockPayload(index: index, stock: stock)
                }
            }

            var indexedStocks: [IndexedPortfolioStockPayload] = []
            for try await stock in group {
                indexedStocks.append(stock)
            }

            return indexedStocks
                .sorted { $0.index < $1.index }
                .map(\.stock)
        }

        return portfolio.map { stock in
            (quote: stock.quote, profile: stock.profile)
        }
    }

    func fetchLiveStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload {
        async let recommendationTask = client.fetchRecommendations(symbol: stock.symbol)
        async let articlesTask = client.fetchCompanyNews(symbol: stock.symbol)
        async let annualReportsTask = client.fetchFinancialReports(symbol: stock.symbol, frequency: "annual")
        async let quarterlyReportsTask = client.fetchFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = client.fetchEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = client.fetchEarningsCalendar(symbol: stock.symbol)

        let recommendations = try await recommendationTask
        let articles = try await articlesTask
        let annualReports = try await annualReportsTask
        let quarterlyReports = try await quarterlyReportsTask
        let earningsHistory = try await earningsHistoryTask
        let earningsCalendar = try await earningsCalendarTask

        return (
            recommendations: recommendations,
            articles: articles,
            annualReports: annualReports,
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )
    }

    func fetchLiveAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload {
        async let recommendationsTask = client.fetchRecommendations(symbol: stock.symbol)
        async let priceTargetTask = client.fetchPriceTarget(symbol: stock.symbol)

        let recommendations = try await recommendationsTask
        let priceTarget = try await priceTargetTask

        return (
            recommendations: recommendations,
            priceTarget: priceTarget
        )
    }

    func fetchLiveMarketSentimentSections(for stock: Stock) async throws -> [FinnhubNewsDTO] {
        try await client.fetchCompanyNews(symbol: stock.symbol)
    }

    func fetchLiveEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        async let quarterlyReportsTask = client.fetchFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = client.fetchEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = client.fetchEarningsCalendar(symbol: stock.symbol)

        let quarterlyReports = try await quarterlyReportsTask
        let earningsHistory = try await earningsHistoryTask
        let earningsCalendar = try await earningsCalendarTask

        return (
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )
    }

    func fetchPortfolioStock(for descriptor: SupportedStockDescriptor) async throws -> PortfolioStockRemotePayload {
        async let quoteTask = client.fetchQuote(symbol: descriptor.symbol)
        async let profileTask = client.fetchCompanyProfile(symbol: descriptor.symbol)

        let quote = try await quoteTask
        let profile = try? await profileTask

        return (quote: quote, profile: profile)
    }
}
