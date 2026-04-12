import Foundation

struct StocksRemoteTransformer {
    private let calendar: Calendar
    private let referenceDateProvider: () -> Date

    init(
        calendar: Calendar = .autoupdatingCurrent,
        referenceDateProvider: @escaping () -> Date = Date.init
    ) {
        self.calendar = calendar
        self.referenceDateProvider = referenceDateProvider
    }

    func makeStocksOverview(from overviewPayload: StocksOverviewRemotePayload) -> StocksOverview {
        StocksOverview(
            portfolio: overviewPayload.portfolio.map(makeStock)
        )
    }

    func makeStock(from payload: StockOverviewRemotePayload) -> Stock {
        Stock(
            symbol: payload.symbol,
            companyName: payload.profile?.trimmedName ?? payload.companyName,
            price: payload.quote.currentPrice,
            changePercent: payload.quote.changePercent,
            logoURL: payload.profile?.logoURL
        )
    }

    func makeSearchResult(from result: StockSearchResultRemoteModel) -> StockSearchResult? {
        let symbol = result.symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !symbol.isEmpty else {
            return nil
        }

        let displaySymbol = result.displaySymbol.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = result.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let type = result.type.trimmingCharacters(in: .whitespacesAndNewlines)

        return StockSearchResult(
            symbol: symbol,
            displaySymbol: displaySymbol.isEmpty ? symbol : displaySymbol,
            companyName: description.isEmpty ? symbol : description,
            type: type
        )
    }

    func makeStockInsights(
        recommendations: [StockRecommendationRemoteModel],
        articles: [SentimentArticleRemoteModel],
        annualReports: [FinancialReportRemoteModel],
        quarterlyReports: [FinancialReportRemoteModel],
        earningsHistory: [EarningsHistoryRemoteModel],
        earningsCalendar: [EarningsCalendarRemoteModel]
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
        recommendations: [StockRecommendationRemoteModel],
        priceTarget: StockPriceTargetRemoteModel
    ) -> AnalystForecastsContent {
        AnalystForecastsContent(
            overview: makeAnalystOverview(
                from: recommendations,
                priceTarget: priceTarget
            ),
            forecasts: []
        )
    }

    func makeSentimentSections(from articles: [SentimentArticleRemoteModel]) -> [SentimentSection] {
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
        quarterlyReports: [FinancialReportRemoteModel],
        earningsHistory: [EarningsHistoryRemoteModel],
        earningsCalendar: [EarningsCalendarRemoteModel]
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

private extension StocksRemoteTransformer {
    func makeForecastSummary(from recommendations: [StockRecommendationRemoteModel]) -> [ForecastSummaryMetric] {
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
        from recommendations: [StockRecommendationRemoteModel],
        priceTarget: StockPriceTargetRemoteModel
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

    func resolvedAverageTarget(from priceTarget: StockPriceTargetRemoteModel) -> Double {
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
        annualReports: [FinancialReportRemoteModel],
        quarterlyReports: [FinancialReportRemoteModel],
        earningsHistory: [EarningsHistoryRemoteModel],
        earningsCalendar: [EarningsCalendarRemoteModel]
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

    func makeAnnualActualValues(from reports: [FinancialReportRemoteModel]) -> [AnnualFinancialValue] {
        reports
            .filter { $0.quarter == 0 }
            .compactMap { report in
                guard
                    let revenue = report.revenueValue,
                    let eps = report.dilutedEPSValue
                else {
                    return nil
                }

                return AnnualFinancialValue(year: report.year, revenue: revenue, eps: eps)
            }
    }

    func makeEstimatedYearValues(
        quarterlyReports: [FinancialReportRemoteModel],
        earningsHistory: [EarningsHistoryRemoteModel],
        earningsCalendar: [EarningsCalendarRemoteModel]
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
        quarterlyReports: [FinancialReportRemoteModel],
        earningsHistory: [EarningsHistoryRemoteModel],
        earningsCalendar: [EarningsCalendarRemoteModel]
    ) -> [QuarterKey: QuarterFinancialValue] {
        var valuesByQuarter: [QuarterKey: QuarterFinancialValue] = [:]

        for report in quarterlyReports where (1...4).contains(report.quarter) {
            let key = QuarterKey(year: report.year, quarter: report.quarter)
            var value = valuesByQuarter[key] ?? QuarterFinancialValue()
            value.revenueActual = report.revenueValue
            value.epsActual = report.dilutedEPSValue
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

    func classifySentiment(for article: SentimentArticleRemoteModel) -> StockMarketSignal? {
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

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: day).uppercased()
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

    func abbreviatedCurrency(_ value: Double, scale: CurrencyScale) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = scale == .billions ? 1 : 2
        formatter.minimumFractionDigits = 0

        let normalizedValue: Double
        switch scale {
        case .plain:
            normalizedValue = value
        case .billions:
            normalizedValue = value / 1_000_000_000
        }

        let prefix = formatter.string(from: NSNumber(value: normalizedValue)) ?? "$0"
        return scale == .billions ? "\(prefix)B" : prefix
    }

    func deltaText(current: Double, previous: Double?) -> String? {
        guard let previous else {
            return nil
        }

        let delta = current - previous
        let prefix = delta >= 0 ? "+" : "-"
        return "\(prefix)\(abbreviatedCurrency(abs(delta), scale: .plain))"
    }

    func deltaPercent(current: Double, previous: Double?) -> Double? {
        guard let previous, previous != 0 else {
            return nil
        }

        return ((current - previous) / abs(previous)) * 100
    }

    func fileDate(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: value)
    }
}
