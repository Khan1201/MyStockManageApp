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

    func fetchStocksOverview() async throws -> StocksOverviewRemotePayload {
        try await fetchLiveStocksOverview()
    }

    func fetchStock(symbol: String) async throws -> StockOverviewRemotePayload {
        try await fetchStock(
            for: SupportedStockDescriptor(
                symbol: symbol,
                companyName: symbol
            )
        )
    }

    func searchStocks(query: String) async throws -> [StockSearchResultRemoteModel] {
        let envelope = try await service.searchStocks(query: query)
        return envelope.result.map(transformer.makeSearchResult(from:))
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
    func fetchLiveStocksOverview() async throws -> StocksOverviewRemotePayload {
        let portfolio = try await fetchStockPayloads(for: SupportedStockDescriptor.portfolioDescriptors)

        return StocksOverviewRemotePayload(
            portfolio: portfolio
        )
    }

    func fetchStockPayloads(
        for descriptors: [SupportedStockDescriptor]
    ) async throws -> [StockOverviewRemotePayload] {
        try await withThrowingTaskGroup(of: IndexedStockOverviewPayload.self) { group in
            for (index, descriptor) in descriptors.enumerated() {
                group.addTask {
                    let stock = try await fetchStock(for: descriptor)
                    return IndexedStockOverviewPayload(index: index, stock: stock)
                }
            }

            var indexedStocks: [IndexedStockOverviewPayload] = []
            for try await stock in group {
                indexedStocks.append(stock)
            }

            return indexedStocks
                .sorted { $0.index < $1.index }
                .map(\.stock)
        }
    }

    func fetchLiveStockInsights(for stock: Stock) async throws -> StockInsightsRemotePayload {
        async let recommendationsTask = fetchAvailableRecommendations(symbol: stock.symbol)
        async let articlesTask = fetchAvailableSentimentArticles(symbol: stock.symbol)
        async let annualReportsTask = fetchAvailableFinancialReports(symbol: stock.symbol, frequency: "annual")
        async let quarterlyReportsTask = fetchAvailableFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = fetchAvailableEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = fetchAvailableEarningsCalendar(symbol: stock.symbol)

        return StockInsightsRemotePayload(
            recommendations: await recommendationsTask,
            articles: await articlesTask,
            annualReports: await annualReportsTask,
            quarterlyReports: await quarterlyReportsTask,
            earningsHistory: await earningsHistoryTask,
            earningsCalendar: await earningsCalendarTask
        )
    }

    func fetchLiveAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload {
        async let recommendationsTask = fetchAvailableRecommendations(symbol: stock.symbol)
        async let priceTargetTask = fetchAvailablePriceTarget(symbol: stock.symbol)

        return AnalystForecastsRemotePayload(
            recommendations: await recommendationsTask,
            priceTarget: await priceTargetTask
        )
    }

    func fetchLiveMarketSentimentSections(for stock: Stock) async throws -> [SentimentArticleRemoteModel] {
        await fetchAvailableSentimentArticles(symbol: stock.symbol)
    }

    func fetchLiveEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        async let quarterlyReportsTask = fetchAvailableFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = fetchAvailableEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = fetchAvailableEarningsCalendar(symbol: stock.symbol)

        return EarningsRevenueRemotePayload(
            quarterlyReports: await quarterlyReportsTask,
            earningsHistory: await earningsHistoryTask,
            earningsCalendar: await earningsCalendarTask
        )
    }

    func fetchStock(for descriptor: SupportedStockDescriptor) async throws -> StockOverviewRemotePayload {
        async let quoteTask = service.fetchQuote(symbol: descriptor.symbol)
        async let profileTask = service.fetchCompanyProfile(symbol: descriptor.symbol)

        let quote = try await quoteTask
        let profile = try? await profileTask

        return StockOverviewRemotePayload(
            symbol: descriptor.symbol,
            companyName: descriptor.companyName,
            quote: transformer.makeQuote(from: quote),
            profile: profile.map(transformer.makeProfile(from:))
        )
    }

    func fetchAvailableRecommendations(symbol: String) async -> [StockRecommendationRemoteModel] {
        do {
            let recommendations = try await service.fetchRecommendations(symbol: symbol)
            return recommendations.map(transformer.makeRecommendation(from:))
        } catch {
            return []
        }
    }

    func fetchAvailablePriceTarget(symbol: String) async -> StockPriceTargetRemoteModel {
        do {
            let priceTarget = try await service.fetchPriceTarget(symbol: symbol)
            return transformer.makePriceTarget(from: priceTarget)
        } catch {
            return StockPriceTargetRemoteModel(
                targetHigh: nil,
                targetLow: nil,
                targetMean: nil,
                targetMedian: nil
            )
        }
    }

    func fetchAvailableSentimentArticles(symbol: String) async -> [SentimentArticleRemoteModel] {
        do {
            let articles = try await service.fetchCompanyNews(symbol: symbol)
            return articles.map(transformer.makeSentimentArticle(from:))
        } catch {
            return []
        }
    }

    func fetchAvailableFinancialReports(
        symbol: String,
        frequency: String
    ) async -> [FinancialReportRemoteModel] {
        do {
            let reports = try await service.fetchFinancialReports(symbol: symbol, frequency: frequency)
            return reports.map(transformer.makeFinancialReport(from:))
        } catch {
            return []
        }
    }

    func fetchAvailableEarningsHistory(symbol: String) async -> [EarningsHistoryRemoteModel] {
        do {
            let earningsHistory = try await service.fetchEarningsHistory(symbol: symbol)
            return earningsHistory.map(transformer.makeEarningsHistory(from:))
        } catch {
            return []
        }
    }

    func fetchAvailableEarningsCalendar(symbol: String) async -> [EarningsCalendarRemoteModel] {
        do {
            let earningsCalendar = try await service.fetchEarningsCalendar(symbol: symbol)
            return earningsCalendar.map(transformer.makeEarningsCalendar(from:))
        } catch {
            return []
        }
    }
}
