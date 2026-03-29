import Foundation

struct StocksFinnhubTransformer {
    static let portfolioDescriptors: [SupportedStockDescriptor] = [
        .init(symbol: "AAPL", companyName: "Apple Inc.", brand: .apple),
        .init(symbol: "MSFT", companyName: "Microsoft Corp", brand: .microsoft),
        .init(symbol: "TSLA", companyName: "Tesla, Inc.", brand: .tesla),
        .init(symbol: "NVDA", companyName: "NVIDIA Corp", brand: .nvidia),
        .init(symbol: "GOOGL", companyName: "Alphabet Inc.", brand: .google)
    ]

    static let searchableDescriptors: [SupportedStockDescriptor] = [
        .init(symbol: "AAPL", companyName: "Apple Inc.", brand: .apple),
        .init(symbol: "AMZN", companyName: "Amazon.com, Inc.", brand: .amazon),
        .init(symbol: "AMD", companyName: "Advanced Micro Devices, Inc.", brand: .amd),
        .init(symbol: "ADBE", companyName: "Adobe Inc.", brand: .adobe),
        .init(symbol: "MSFT", companyName: "Microsoft Corp", brand: .microsoft),
        .init(symbol: "TSLA", companyName: "Tesla, Inc.", brand: .tesla),
        .init(symbol: "NVDA", companyName: "NVIDIA Corp", brand: .nvidia),
        .init(symbol: "GOOGL", companyName: "Alphabet Inc.", brand: .google)
    ]

    private let calendar: Calendar
    private let referenceDateProvider: () -> Date

    init(
        calendar: Calendar = .autoupdatingCurrent,
        referenceDateProvider: @escaping () -> Date = Date.init
    ) {
        self.calendar = calendar
        self.referenceDateProvider = referenceDateProvider
    }

    func makeStocksOverview(from portfolioPayload: [PortfolioStockRemotePayload]) -> StocksOverview {
        StocksOverview(
            portfolio: zip(Self.portfolioDescriptors, portfolioPayload).compactMap(makePortfolioStock),
            searchableStocks: Self.searchableDescriptors.map(makeSearchResultStock)
        )
    }

    func makeStockInsights(
        recommendations: [FinnhubRecommendationDTO],
        articles: [FinnhubNewsDTO],
        annualReports: [FinnhubFinancialReportDTO],
        quarterlyReports: [FinnhubFinancialReportDTO],
        earningsHistory: [FinnhubEarningsHistoryDTO],
        earningsCalendar: [FinnhubEarningsCalendarDTO]
    ) -> StockInsights {
        let sentimentSections = makeSentimentSections(from: articles)
        let earningsSummary = makeStockEstimateSnapshots(
            annualReports: annualReports,
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )

        return StockInsights(
            forecastSummary: makeForecastSummary(from: recommendations),
            sentimentSummary: makeSentimentSummary(from: sentimentSections),
            earningsEstimates: earningsSummary
        )
    }

    func makeAnalystForecasts(
        recommendations: [FinnhubRecommendationDTO],
        priceTarget: FinnhubPriceTargetDTO
    ) -> AnalystForecastsContent {
        AnalystForecastsContent(
            overview: makeAnalystOverview(
                from: recommendations,
                priceTarget: priceTarget
            ),
            forecasts: []
        )
    }

    func makeSentimentSections(from articles: [FinnhubNewsDTO]) -> [SentimentSection] {
        let classifiedArticles = articles
            .sorted { $0.datetime > $1.datetime }
            .compactMap { article -> ClassifiedSentimentArticle? in
                guard let signal = classifySentiment(for: article) else {
                    return nil
                }
                return ClassifiedSentimentArticle(article: article, signal: signal)
            }
            .filter { !$0.article.headline.isEmpty }
            .prefix(12)

        let grouped = Dictionary(grouping: classifiedArticles) { article in
            calendar.startOfDay(for: article.date)
        }

        return grouped.keys
            .sorted(by: >)
            .map { date in
                let items = grouped[date, default: []]
                    .sorted { $0.article.datetime > $1.article.datetime }
                    .map(makeSentimentArticle)
                return SentimentSection(
                    id: sectionID(from: date),
                    title: sentimentSectionTitle(for: date),
                    items: items
                )
            }
    }

    func makeEarningsYearRecords(
        quarterlyReports: [FinnhubFinancialReportDTO],
        earningsHistory: [FinnhubEarningsHistoryDTO],
        earningsCalendar: [FinnhubEarningsCalendarDTO]
    ) -> [EarningsYearRecord] {
        let mergedQuarters = mergeQuarterlyData(
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )
        let years = Set(mergedQuarters.keys.map(\.year))

        return years.sorted(by: >).compactMap { year in
            let quarterItems = (1...4)
                .reversed()
                .compactMap { quarter -> EarningsQuarterRecord? in
                    let key = QuarterKey(year: year, quarter: quarter)
                    guard let quarterData = mergedQuarters[key] else {
                        return nil
                    }
                    return makeQuarterRecord(year: year, quarter: quarter, data: quarterData)
                }

            guard !quarterItems.isEmpty else {
                return nil
            }

            return EarningsYearRecord(year: year, quarterItems: quarterItems)
        }
    }
}

private extension StocksFinnhubTransformer {
    func makePortfolioStock(from pair: (SupportedStockDescriptor, PortfolioStockRemotePayload)) -> Stock {
        let descriptor = pair.0
        let payload = pair.1
        return Stock(
            symbol: descriptor.symbol,
            companyName: payload.profile?.trimmedName ?? descriptor.companyName,
            price: payload.quote.currentPrice,
            changePercent: payload.quote.changePercent,
            brand: descriptor.brand
        )
    }

    func makeSearchResultStock(from descriptor: SupportedStockDescriptor) -> StockSearchResult {
        return StockSearchResult(
            symbol: descriptor.symbol,
            companyName: descriptor.companyName,
            brand: descriptor.brand
        )
    }

    func makeForecastSummary(from recommendations: [FinnhubRecommendationDTO]) -> [ForecastSummaryMetric] {
        guard let latest = recommendations.sorted(by: { $0.period > $1.period }).first else {
            return []
        }

        return [
            .init(id: "strong_buy", recommendation: .strongBuy, count: latest.strongBuy),
            .init(id: "buy", recommendation: .buy, count: latest.buy),
            .init(id: "hold", recommendation: .hold, count: latest.hold),
            .init(id: "sell", recommendation: .sell, count: latest.sell),
            .init(id: "strong_sell", recommendation: .strongSell, count: latest.strongSell)
        ]
    }

    func makeAnalystOverview(
        from recommendations: [FinnhubRecommendationDTO],
        priceTarget: FinnhubPriceTargetDTO
    ) -> AnalystForecastOverview {
        let averageTarget = resolvedAverageTarget(from: priceTarget)

        guard let latest = recommendations.sorted(by: { $0.period > $1.period }).first else {
            return AnalystForecastOverview(
                averageTarget: averageTarget,
                consensus: .neutral,
                analystsCount: 0
            )
        }

        let totalAnalysts = latest.buy + latest.hold + latest.sell + latest.strongBuy + latest.strongSell
        let weightedSum =
            Double(latest.strongBuy * 5) +
            Double(latest.buy * 4) +
            Double(latest.hold * 3) +
            Double(latest.sell * 2) +
            Double(latest.strongSell)
        let averageScore = totalAnalysts == 0 ? 0 : weightedSum / Double(totalAnalysts)

        return AnalystForecastOverview(
            averageTarget: averageTarget,
            consensus: analystConsensus(for: averageScore),
            analystsCount: totalAnalysts
        )
    }

    func resolvedAverageTarget(from priceTarget: FinnhubPriceTargetDTO) -> Double {
        priceTarget.targetMean
            ?? priceTarget.targetMedian
            ?? priceTarget.targetHigh
            ?? priceTarget.targetLow
            ?? 0
    }

    func makeSentimentSummary(from sections: [SentimentSection]) -> [SentimentSummaryMetric] {
        let articles = sections.flatMap(\.items)
        let bullishCount = articles.filter { $0.signal == .bullish }.count
        let bearishCount = articles.filter { $0.signal == .bearish }.count

        return [
            .init(id: "bullish", signal: .bullish, count: bullishCount),
            .init(id: "bearish", signal: .bearish, count: bearishCount)
        ]
    }

    func makeSentimentArticle(from article: ClassifiedSentimentArticle) -> SentimentArticle {
        SentimentArticle(
            id: "\(article.article.id)",
            headline: article.article.headline,
            sourceName: article.article.source,
            publishedAtText: timeString(from: article.date),
            signal: article.signal
        )
    }

    func makeStockEstimateSnapshots(
        annualReports: [FinnhubFinancialReportDTO],
        quarterlyReports: [FinnhubFinancialReportDTO],
        earningsHistory: [FinnhubEarningsHistoryDTO],
        earningsCalendar: [FinnhubEarningsCalendarDTO]
    ) -> [StockEstimateSnapshot] {
        let annualActuals = makeAnnualActualValues(from: annualReports)
        let estimatedYears = makeEstimatedYearValues(
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )

        var snapshots = annualActuals
            .sorted { $0.year < $1.year }
            .suffix(4)
            .map { actual -> StockEstimateSnapshot in
                let previous = annualActuals.first { $0.year == actual.year - 1 }

                return StockEstimateSnapshot(
                    id: "\(actual.year)_actual",
                    year: actual.year,
                    stage: .actual,
                    revenueText: abbreviatedCurrency(actual.revenue, scale: .billions),
                    revenueDeltaText: deltaText(current: actual.revenue, previous: previous?.revenue),
                    revenueDeltaPercent: deltaPercent(current: actual.revenue, previous: previous?.revenue),
                    epsText: abbreviatedCurrency(actual.eps, scale: .plain),
                    epsDeltaText: deltaText(current: actual.eps, previous: previous?.eps),
                    epsDeltaPercent: deltaPercent(current: actual.eps, previous: previous?.eps)
                )
            }

        snapshots.append(
            contentsOf: estimatedYears
                .sorted { $0.year < $1.year }
                .map { estimate in
                    let previous = annualActuals.first { $0.year == estimate.year - 1 }

                    return StockEstimateSnapshot(
                        id: "\(estimate.year)_est",
                        year: estimate.year,
                        stage: .estimated,
                        revenueText: abbreviatedCurrency(estimate.revenue, scale: .billions),
                        revenueDeltaText: deltaText(current: estimate.revenue, previous: previous?.revenue),
                        revenueDeltaPercent: deltaPercent(current: estimate.revenue, previous: previous?.revenue),
                        epsText: abbreviatedCurrency(estimate.eps, scale: .plain),
                        epsDeltaText: deltaText(current: estimate.eps, previous: previous?.eps),
                        epsDeltaPercent: deltaPercent(current: estimate.eps, previous: previous?.eps)
                    )
                }
        )

        return snapshots
    }

    func makeAnnualActualValues(from reports: [FinnhubFinancialReportDTO]) -> [AnnualFinancialValue] {
        reports
            .filter { $0.quarter == 0 }
            .compactMap { report in
                guard
                    let revenue = report.report.incomeStatement.revenueValue,
                    let eps = report.report.incomeStatement.dilutedEPSValue
                else {
                    return nil
                }

                return AnnualFinancialValue(year: report.year, revenue: revenue, eps: eps)
            }
    }

    func makeEstimatedYearValues(
        quarterlyReports: [FinnhubFinancialReportDTO],
        earningsHistory: [FinnhubEarningsHistoryDTO],
        earningsCalendar: [FinnhubEarningsCalendarDTO]
    ) -> [AnnualFinancialValue] {
        let mergedQuarters = mergeQuarterlyData(
            quarterlyReports: quarterlyReports,
            earningsHistory: earningsHistory,
            earningsCalendar: earningsCalendar
        )
        let years = Set(mergedQuarters.keys.map(\.year))

        return years.compactMap { year in
            let quarters = (1...4).compactMap { quarter in
                mergedQuarters[QuarterKey(year: year, quarter: quarter)]
            }

            guard quarters.count == 4 else {
                return nil
            }

            let revenueValues = quarters.compactMap { $0.revenueActual ?? $0.revenueEstimate }
            let epsValues = quarters.compactMap { $0.epsActual ?? $0.epsEstimate }

            guard revenueValues.count == 4, epsValues.count == 4 else {
                return nil
            }

            return AnnualFinancialValue(
                year: year,
                revenue: revenueValues.reduce(0, +),
                eps: epsValues.reduce(0, +)
            )
        }
    }

    func mergeQuarterlyData(
        quarterlyReports: [FinnhubFinancialReportDTO],
        earningsHistory: [FinnhubEarningsHistoryDTO],
        earningsCalendar: [FinnhubEarningsCalendarDTO]
    ) -> [QuarterKey: QuarterFinancialValue] {
        var valuesByQuarter: [QuarterKey: QuarterFinancialValue] = [:]

        for report in quarterlyReports where (1...4).contains(report.quarter) {
            let key = QuarterKey(year: report.year, quarter: report.quarter)
            var value = valuesByQuarter[key] ?? QuarterFinancialValue()
            value.revenueActual = report.report.incomeStatement.revenueValue
            value.epsActual = report.report.incomeStatement.dilutedEPSValue
            value.filedDate = fileDate(from: report.filedDate)
            valuesByQuarter[key] = value
        }

        for earnings in earningsHistory {
            let key = QuarterKey(year: earnings.year, quarter: earnings.quarter)
            var value = valuesByQuarter[key] ?? QuarterFinancialValue()
            value.epsActual = earnings.actual ?? value.epsActual
            value.epsEstimate = earnings.estimate
            valuesByQuarter[key] = value
        }

        for earnings in earningsCalendar {
            let key = QuarterKey(year: earnings.year, quarter: earnings.quarter)
            var value = valuesByQuarter[key] ?? QuarterFinancialValue()
            value.revenueEstimate = earnings.revenueEstimate
            value.epsEstimate = earnings.epsEstimate
            valuesByQuarter[key] = value
        }

        return valuesByQuarter
    }

    func makeQuarterRecord(
        year: Int,
        quarter: Int,
        data: QuarterFinancialValue
    ) -> EarningsQuarterRecord? {
        let quarterTitle = "Q\(quarter) \(year)"
        let revenueValue = data.revenueActual ?? data.revenueEstimate
        let epsValue = data.epsActual ?? data.epsEstimate

        guard let revenueValue, let epsValue else {
            return nil
        }

        let revenuePerformance = performancePercent(actual: data.revenueActual, estimate: data.revenueEstimate)
        let epsPerformance = performancePercent(actual: data.epsActual, estimate: data.epsEstimate)
        let isProjected = data.revenueActual == nil && data.epsActual == nil

        return EarningsQuarterRecord(
            id: "\(year)_q\(quarter)",
            quarterTitle: quarterTitle,
            trailingStatusText: isProjected ? "ESTIMATED" : reportedStatusText(from: data.filedDate),
            state: quarterState(
                revenuePerformancePercent: revenuePerformance,
                epsPerformancePercent: epsPerformance,
                isProjected: isProjected
            ),
            revenueValueText: abbreviatedCurrency(revenueValue, scale: .billions),
            revenueEstimateText: estimateText(for: data.revenueEstimate, scale: .billions, isProjected: isProjected),
            revenuePerformancePercent: revenuePerformance,
            epsValueText: abbreviatedCurrency(epsValue, scale: .plain),
            epsEstimateText: estimateText(for: data.epsEstimate, scale: .plain, isProjected: isProjected),
            epsPerformancePercent: epsPerformance
        )
    }

    func classifySentiment(for article: FinnhubNewsDTO) -> StockMarketSignal? {
        let text = "\(article.headline) \(article.summary)".localizedLowercase
        let bullishScore = bullishKeywords.reduce(into: 0) { partialResult, keyword in
            if text.contains(keyword) {
                partialResult += 1
            }
        }
        let bearishScore = bearishKeywords.reduce(into: 0) { partialResult, keyword in
            if text.contains(keyword) {
                partialResult += 1
            }
        }

        guard bullishScore != bearishScore else {
            return nil
        }

        return bullishScore > bearishScore ? .bullish : .bearish
    }

    var bullishKeywords: [String] {
        [
            "surge", "gain", "gains", "beat", "beats", "buy", "bullish", "upside",
            "approved", "record", "strong", "growth", "expansion", "rally",
            "outperform", "upgrade", "boost", "higher", "jump", "improve", "improves"
        ]
    }

    var bearishKeywords: [String] {
        [
            "fall", "falls", "fell", "drop", "drops", "sell", "bearish", "miss",
            "cuts", "cut", "lawsuit", "risk", "risks", "slump", "decline",
            "lower", "downgrade", "investigation", "delay", "warning", "hike",
            "correction", "pressure", "sink", "sheds", "tumble", "down"
        ]
    }

    func analystConsensus(for averageScore: Double) -> AnalystRecommendation {
        switch averageScore {
        case 4.5...:
            return .strongBuy
        case 3.5..<4.5:
            return .buy
        case 2.5..<3.5:
            return .hold
        case 1.5..<2.5:
            return .sell
        default:
            return .strongSell
        }
    }

    func quarterState(
        revenuePerformancePercent: Double?,
        epsPerformancePercent: Double?,
        isProjected: Bool
    ) -> EarningsQuarterState {
        if isProjected {
            return .projected
        }

        let scores = [revenuePerformancePercent, epsPerformancePercent].compactMap { $0 }
        guard !scores.isEmpty else {
            return .projected
        }

        if scores.allSatisfy({ $0 >= 0 }) {
            return .beat
        }

        if scores.allSatisfy({ $0 < 0 }) {
            return .miss
        }

        return .partialMiss
    }

    func performancePercent(actual: Double?, estimate: Double?) -> Double? {
        guard let actual, let estimate, estimate != 0 else {
            return nil
        }

        return ((actual - estimate) / abs(estimate)) * 100
    }

    func estimateText(for value: Double?, scale: CurrencyScale, isProjected: Bool) -> String? {
        guard let value, !isProjected else {
            return nil
        }

        return "Est. \(abbreviatedCurrency(value, scale: scale))"
    }

    func reportedStatusText(from filedDate: Date?) -> String {
        guard let filedDate else {
            return "REPORTED"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return "REPORTED \(formatter.string(from: filedDate).uppercased())"
    }

    func sentimentSectionTitle(for date: Date) -> String {
        let day = calendar.startOfDay(for: date)
        let referenceDay = calendar.startOfDay(for: referenceDateProvider())

        if day == referenceDay {
            return "TODAY"
        }

        if day == calendar.date(byAdding: .day, value: -1, to: referenceDay) {
            return "YESTERDAY"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date).uppercased()
    }

    func sectionID(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    func fileDate(from rawValue: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: rawValue)
    }

    func deltaPercent(current: Double, previous: Double?) -> Double? {
        guard let previous, previous != 0 else {
            return nil
        }

        return ((current - previous) / abs(previous)) * 100
    }

    func deltaText(current: Double, previous: Double?) -> String? {
        guard let percent = deltaPercent(current: current, previous: previous) else {
            return nil
        }

        let sign = percent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percent))%"
    }

    func abbreviatedCurrency(_ value: Double, scale: CurrencyScale) -> String {
        let absoluteValue = abs(value)
        let sign = value < 0 ? "-" : ""

        switch scale {
        case .plain:
            return "\(sign)$\(String(format: "%.2f", absoluteValue))"
        case .billions:
            return "\(sign)$\(String(format: "%.1f", absoluteValue / 1_000_000_000))B"
        }
    }
}
