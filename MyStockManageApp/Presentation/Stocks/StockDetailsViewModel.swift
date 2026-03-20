import SwiftUI

@MainActor
final class StockDetailsViewModel: ObservableObject {
    @Published private(set) var isAddedToWatchlist: Bool
    @Published private(set) var isPresentingAnalystForecasts: Bool
    @Published private(set) var isPresentingMarketSentiment: Bool
    @Published private(set) var isPresentingEarningsRevenueDetails: Bool
    @Published private(set) var analystForecasts: [StockForecastItem]
    @Published private(set) var sentimentItems: [StockSentimentItem]
    @Published private(set) var earningsEstimateRows: [StockEstimateRow]

    let stock: PortfolioStock

    private let fetchStockInsightsUseCase: FetchStockInsightsUseCase
    private let fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase
    private let fetchMarketSentimentUseCase: FetchMarketSentimentUseCase
    private let fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase
    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        isAddedToWatchlist: Bool = false,
        fetchStockInsightsUseCase: FetchStockInsightsUseCase = .noop,
        fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase = .noop,
        fetchMarketSentimentUseCase: FetchMarketSentimentUseCase = .noop,
        fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase = .noop,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.stock = stock
        self.isAddedToWatchlist = isAddedToWatchlist
        self.fetchStockInsightsUseCase = fetchStockInsightsUseCase
        self.fetchAnalystForecastsUseCase = fetchAnalystForecastsUseCase
        self.fetchMarketSentimentUseCase = fetchMarketSentimentUseCase
        self.fetchEarningsRevenueUseCase = fetchEarningsRevenueUseCase
        self.isPresentingAnalystForecasts = false
        self.isPresentingMarketSentiment = false
        self.isPresentingEarningsRevenueDetails = false
        self.analystForecasts = []
        self.sentimentItems = []
        self.earningsEstimateRows = []
        self.dismissAction = dismissAction
    }

    var priceText: String {
        stock.priceText
    }

    var priceChangeText: String {
        "\(formattedSignedCurrency(priceChangeAmount)) (\(formattedPercentMagnitude))"
    }

    var priceChangeColor: Color {
        stock.changeDirection.foregroundColor
    }

    var addButtonSymbolName: String {
        isAddedToWatchlist ? "checkmark" : "plus"
    }

    var addButtonAccessibilityLabel: LocalizedStringResource {
        isAddedToWatchlist ? "Added to watchlist" : "Add to watchlist"
    }

    var analystForecastsViewModel: AnalystForecastsViewModel {
        AnalystForecastsViewModel(
            stock: stock,
            fetchAnalystForecastsUseCase: fetchAnalystForecastsUseCase,
            dismissAction: didDismissAnalystForecasts
        )
    }

    var marketSentimentViewModel: MarketSentimentViewModel {
        MarketSentimentViewModel(
            stock: stock,
            fetchMarketSentimentUseCase: fetchMarketSentimentUseCase,
            dismissAction: didDismissMarketSentiment
        )
    }

    var earningsRevenueDetailsViewModel: EarningsRevenueDetailsViewModel {
        EarningsRevenueDetailsViewModel(
            stock: stock,
            fetchEarningsRevenueUseCase: fetchEarningsRevenueUseCase,
            dismissAction: didDismissEarningsRevenueDetails
        )
    }

    func loadStockInsights() async {
        do {
            let insights = try await fetchStockInsightsUseCase.execute(stock: stock)
            analystForecasts = insights.forecastSummary.map(Self.makeForecastItem)
            sentimentItems = insights.sentimentSummary.map(Self.makeSentimentItem)
            earningsEstimateRows = insights.earningsEstimates.map(Self.makeEstimateRow)
        } catch {
            analystForecasts = []
            sentimentItems = []
            earningsEstimateRows = []
        }
    }

    func didTapCloseButton() {
        dismissAction()
    }

    func didTapAddButton() {
        isAddedToWatchlist.toggle()
    }

    func didTapAnalystForecastsSeeAll() {
        isPresentingAnalystForecasts = true
    }

    func didDismissAnalystForecasts() {
        isPresentingAnalystForecasts = false
    }

    func didTapMarketSentimentSeeAll() {
        isPresentingMarketSentiment = true
    }

    func didDismissMarketSentiment() {
        isPresentingMarketSentiment = false
    }

    func didTapEarningsEstimatesSeeAll() {
        isPresentingEarningsRevenueDetails = true
    }

    func didDismissEarningsRevenueDetails() {
        isPresentingEarningsRevenueDetails = false
    }

    private var priceChangeAmount: Double {
        let rate = 1 + (stock.changePercent / 100)
        guard rate != 0 else {
            return 0
        }

        return stock.price - (stock.price / rate)
    }

    private var formattedPercentMagnitude: String {
        String(format: "%.2f%%", abs(stock.changePercent))
    }

    private func formattedSignedCurrency(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"
        return "\(sign)$\(String(format: "%.2f", abs(value)))"
    }
}

private extension StockDetailsViewModel {
    static func makeForecastItem(_ metric: ForecastSummaryMetric) -> StockForecastItem {
        StockForecastItem(
            id: metric.id,
            title: recommendationTitle(metric.recommendation),
            count: metric.count,
            indicatorColor: recommendationIndicatorColor(metric.recommendation),
            badgeForegroundColor: recommendationBadgeForegroundColor(metric.recommendation),
            badgeBackgroundColor: recommendationBadgeBackgroundColor(metric.recommendation)
        )
    }

    static func makeSentimentItem(_ metric: SentimentSummaryMetric) -> StockSentimentItem {
        StockSentimentItem(
            id: metric.id,
            title: sentimentTitle(metric.signal),
            count: metric.count,
            indicatorColor: metric.signal == .bullish
            ? Color(red: 0.14, green: 0.80, blue: 0.61)
            : Color(red: 0.96, green: 0.29, blue: 0.42),
            badgeForegroundColor: metric.signal.badgeForegroundColor,
            badgeBackgroundColor: metric.signal.badgeBackgroundColor
        )
    }

    static func makeEstimateRow(_ snapshot: StockEstimateSnapshot) -> StockEstimateRow {
        StockEstimateRow(
            id: snapshot.id,
            yearText: "\(snapshot.year)",
            stageText: snapshot.stage == .actual ? "ACTUAL" : "EST",
            stageColor: snapshot.stage == .actual
            ? Color(red: 0.24, green: 0.78, blue: 0.54)
            : Color(red: 1.0, green: 0.41, blue: 0.16),
            revenueText: snapshot.revenueText,
            revenueDeltaText: snapshot.revenueDeltaText,
            revenueDeltaColor: performanceColor(snapshot.revenueDeltaPercent),
            epsText: snapshot.epsText,
            epsDeltaText: snapshot.epsDeltaText,
            epsDeltaColor: performanceColor(snapshot.epsDeltaPercent)
        )
    }

    static func recommendationTitle(_ recommendation: AnalystRecommendation) -> LocalizedStringResource {
        switch recommendation {
        case .strongBuy:
            return "Strong Buy"
        case .buy:
            return "Buy"
        case .hold:
            return "Hold"
        case .neutral:
            return "Neutral"
        case .sell:
            return "Sell"
        case .strongSell:
            return "Strong Sell"
        }
    }

    static func sentimentTitle(_ signal: StockMarketSignal) -> LocalizedStringResource {
        switch signal {
        case .bullish:
            return "Bullish Signals"
        case .bearish:
            return "Bearish Signals"
        }
    }

    static func recommendationIndicatorColor(_ recommendation: AnalystRecommendation) -> Color {
        switch recommendation {
        case .strongBuy:
            return Color(red: 0.14, green: 0.80, blue: 0.61)
        case .buy:
            return Color(red: 0.20, green: 0.76, blue: 0.64)
        case .hold, .neutral:
            return Color(red: 0.58, green: 0.65, blue: 0.75)
        case .sell:
            return Color(red: 0.98, green: 0.55, blue: 0.60)
        case .strongSell:
            return Color(red: 0.96, green: 0.29, blue: 0.42)
        }
    }

    static func recommendationBadgeForegroundColor(_ recommendation: AnalystRecommendation) -> Color {
        switch recommendation {
        case .strongBuy, .buy:
            return Color(red: 0.14, green: 0.72, blue: 0.32)
        case .hold, .neutral:
            return Color(red: 0.38, green: 0.45, blue: 0.55)
        case .sell, .strongSell:
            return Color(red: 0.89, green: 0.23, blue: 0.23)
        }
    }

    static func recommendationBadgeBackgroundColor(_ recommendation: AnalystRecommendation) -> Color {
        switch recommendation {
        case .strongBuy, .buy:
            return Color(red: 0.90, green: 0.98, blue: 0.92)
        case .hold, .neutral:
            return Color(red: 0.95, green: 0.96, blue: 0.98)
        case .sell, .strongSell:
            return Color(red: 1.0, green: 0.92, blue: 0.92)
        }
    }

    static func performanceColor(_ percent: Double?) -> Color? {
        guard let percent else {
            return nil
        }

        return percent >= 0
            ? Color(red: 0.14, green: 0.72, blue: 0.32)
            : Color(red: 0.89, green: 0.23, blue: 0.23)
    }
}
