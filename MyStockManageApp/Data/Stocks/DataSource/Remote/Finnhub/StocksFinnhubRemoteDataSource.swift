import Foundation

struct StocksFinnhubRemoteDataSource: StocksRemoteDataSource {
    private let service: FinnhubService
    private let transformer: FinnhubToRemoteTransformer

    init(
        session: any HTTPClientSession = URLSession.shared,
        configuration: FinnhubConfiguration = .live(),
        calendar: Calendar = .autoupdatingCurrent,
        nowProvider: @escaping () -> Date = Date.init,
        transformer: FinnhubToRemoteTransformer = FinnhubToRemoteTransformer()
    ) {
        self.service = FinnhubService(
            session: session,
            configuration: configuration,
            calendar: calendar,
            nowProvider: nowProvider
        )
        self.transformer = transformer
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

    func fetchMarketSentiment(for stock: Stock) async throws -> [SentimentArticleRemoteModel] {
        try await fetchLiveMarketSentimentSections(for: stock)
    }

    func fetchEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        try await fetchLiveEarningsRevenue(for: stock)
    }
}

private extension StocksFinnhubRemoteDataSource {
    func fetchLiveStocksOverview() async throws -> [PortfolioStockRemotePayload] {
        let portfolio = try await withThrowingTaskGroup(of: IndexedPortfolioStockPayload.self) { group in
            for (index, descriptor) in SupportedStockDescriptor.portfolioDescriptors.enumerated() {
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

        return portfolio
    }

    func fetchLiveStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload {
        async let recommendationTask = service.fetchRecommendations(symbol: stock.symbol)
        async let articlesTask = service.fetchCompanyNews(symbol: stock.symbol)
        async let annualReportsTask = service.fetchFinancialReports(symbol: stock.symbol, frequency: "annual")
        async let quarterlyReportsTask = service.fetchFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = service.fetchEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = service.fetchEarningsCalendar(symbol: stock.symbol)

        let recommendations = try await recommendationTask
        let articles = try await articlesTask
        let annualReports = try await annualReportsTask
        let quarterlyReports = try await quarterlyReportsTask
        let earningsHistory = try await earningsHistoryTask
        let earningsCalendar = try await earningsCalendarTask

        return StockInsightsRemotePayload(
            recommendations: recommendations.map(transformer.makeRecommendation(from:)),
            articles: articles.map(transformer.makeSentimentArticle(from:)),
            annualReports: annualReports.map(transformer.makeFinancialReport(from:)),
            quarterlyReports: quarterlyReports.map(transformer.makeFinancialReport(from:)),
            earningsHistory: earningsHistory.map(transformer.makeEarningsHistory(from:)),
            earningsCalendar: earningsCalendar.map(transformer.makeEarningsCalendar(from:))
        )
    }

    func fetchLiveAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload {
        async let recommendationsTask = service.fetchRecommendations(symbol: stock.symbol)
        async let priceTargetTask = service.fetchPriceTarget(symbol: stock.symbol)

        let recommendations = try await recommendationsTask
        let priceTarget = try await priceTargetTask

        return AnalystForecastsRemotePayload(
            recommendations: recommendations.map(transformer.makeRecommendation(from:)),
            priceTarget: transformer.makePriceTarget(from: priceTarget)
        )
    }

    func fetchLiveMarketSentimentSections(for stock: Stock) async throws -> [SentimentArticleRemoteModel] {
        let articles = try await service.fetchCompanyNews(symbol: stock.symbol)
        return articles.map(transformer.makeSentimentArticle(from:))
    }

    func fetchLiveEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        async let quarterlyReportsTask = service.fetchFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = service.fetchEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = service.fetchEarningsCalendar(symbol: stock.symbol)

        let quarterlyReports = try await quarterlyReportsTask
        let earningsHistory = try await earningsHistoryTask
        let earningsCalendar = try await earningsCalendarTask

        return EarningsRevenueRemotePayload(
            quarterlyReports: quarterlyReports.map(transformer.makeFinancialReport(from:)),
            earningsHistory: earningsHistory.map(transformer.makeEarningsHistory(from:)),
            earningsCalendar: earningsCalendar.map(transformer.makeEarningsCalendar(from:))
        )
    }

    func fetchPortfolioStock(for descriptor: SupportedStockDescriptor) async throws -> PortfolioStockRemotePayload {
        async let quoteTask = service.fetchQuote(symbol: descriptor.symbol)
        async let profileTask = service.fetchCompanyProfile(symbol: descriptor.symbol)

        let quote = try await quoteTask
        let profile = try? await profileTask

        return PortfolioStockRemotePayload(
            quote: transformer.makeQuote(from: quote),
            profile: profile.map(transformer.makeProfile(from:))
        )
    }
}
