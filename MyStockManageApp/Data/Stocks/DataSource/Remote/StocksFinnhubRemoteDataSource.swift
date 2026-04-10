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

        return StockInsightsRemotePayload(
            recommendations: recommendations.map(makeRecommendation(from:)),
            articles: articles.map(makeSentimentArticle(from:)),
            annualReports: annualReports.map(makeFinancialReport(from:)),
            quarterlyReports: quarterlyReports.map(makeFinancialReport(from:)),
            earningsHistory: earningsHistory.map(makeEarningsHistory(from:)),
            earningsCalendar: earningsCalendar.map(makeEarningsCalendar(from:))
        )
    }

    func fetchLiveAnalystForecasts(for stock: Stock) async throws -> AnalystForecastsRemotePayload {
        async let recommendationsTask = client.fetchRecommendations(symbol: stock.symbol)
        async let priceTargetTask = client.fetchPriceTarget(symbol: stock.symbol)

        let recommendations = try await recommendationsTask
        let priceTarget = try await priceTargetTask

        return AnalystForecastsRemotePayload(
            recommendations: recommendations.map(makeRecommendation(from:)),
            priceTarget: makePriceTarget(from: priceTarget)
        )
    }

    func fetchLiveMarketSentimentSections(for stock: Stock) async throws -> [SentimentArticleRemoteModel] {
        let articles = try await client.fetchCompanyNews(symbol: stock.symbol)
        return articles.map { makeSentimentArticle(from: $0) }
    }

    func fetchLiveEarningsRevenue(for stock: Stock) async throws -> EarningsRevenueRemotePayload {
        async let quarterlyReportsTask = client.fetchFinancialReports(symbol: stock.symbol, frequency: "quarterly")
        async let earningsHistoryTask = client.fetchEarningsHistory(symbol: stock.symbol)
        async let earningsCalendarTask = client.fetchEarningsCalendar(symbol: stock.symbol)

        let quarterlyReports = try await quarterlyReportsTask
        let earningsHistory = try await earningsHistoryTask
        let earningsCalendar = try await earningsCalendarTask

        return EarningsRevenueRemotePayload(
            quarterlyReports: quarterlyReports.map(makeFinancialReport(from:)),
            earningsHistory: earningsHistory.map(makeEarningsHistory(from:)),
            earningsCalendar: earningsCalendar.map(makeEarningsCalendar(from:))
        )
    }

    func fetchPortfolioStock(for descriptor: SupportedStockDescriptor) async throws -> PortfolioStockRemotePayload {
        async let quoteTask = client.fetchQuote(symbol: descriptor.symbol)
        async let profileTask = client.fetchCompanyProfile(symbol: descriptor.symbol)

        let quote = try await quoteTask
        let profile = try? await profileTask

        return PortfolioStockRemotePayload(
            quote: makeQuote(from: quote),
            profile: profile.map { makeProfile(from: $0) }
        )
    }

    func makeQuote(from quote: FinnhubQuoteDTO) -> StockQuoteRemoteModel {
        StockQuoteRemoteModel(
            currentPrice: quote.currentPrice,
            changePercent: quote.changePercent
        )
    }

    func makeProfile(from profile: FinnhubProfileDTO) -> StockProfileRemoteModel {
        StockProfileRemoteModel(name: profile.name)
    }

    func makeRecommendation(from recommendation: FinnhubRecommendationDTO) -> StockRecommendationRemoteModel {
        StockRecommendationRemoteModel(
            buy: recommendation.buy,
            hold: recommendation.hold,
            period: recommendation.period,
            sell: recommendation.sell,
            strongBuy: recommendation.strongBuy,
            strongSell: recommendation.strongSell
        )
    }

    func makePriceTarget(from priceTarget: FinnhubPriceTargetDTO) -> StockPriceTargetRemoteModel {
        StockPriceTargetRemoteModel(
            targetHigh: priceTarget.targetHigh,
            targetLow: priceTarget.targetLow,
            targetMean: priceTarget.targetMean,
            targetMedian: priceTarget.targetMedian
        )
    }

    func makeSentimentArticle(from article: FinnhubNewsDTO) -> SentimentArticleRemoteModel {
        SentimentArticleRemoteModel(
            datetime: article.datetime,
            headline: article.headline,
            id: article.id,
            source: article.source,
            summary: article.summary
        )
    }

    func makeFinancialReport(from report: FinnhubFinancialReportDTO) -> FinancialReportRemoteModel {
        FinancialReportRemoteModel(
            filedDate: report.filedDate,
            quarter: report.quarter,
            revenueValue: report.report.incomeStatement.revenueValue,
            dilutedEPSValue: report.report.incomeStatement.dilutedEPSValue,
            year: report.year
        )
    }

    func makeEarningsHistory(from earnings: FinnhubEarningsHistoryDTO) -> EarningsHistoryRemoteModel {
        EarningsHistoryRemoteModel(
            actual: earnings.actual,
            estimate: earnings.estimate,
            quarter: earnings.quarter,
            year: earnings.year
        )
    }

    func makeEarningsCalendar(from earnings: FinnhubEarningsCalendarDTO) -> EarningsCalendarRemoteModel {
        EarningsCalendarRemoteModel(
            date: earnings.date,
            epsEstimate: earnings.epsEstimate,
            quarter: earnings.quarter,
            revenueEstimate: earnings.revenueEstimate,
            year: earnings.year
        )
    }
}
