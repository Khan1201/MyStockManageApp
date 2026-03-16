import SwiftUI

final class StockDetailsViewModel: ObservableObject {
    @Published private(set) var isAddedToWatchlist: Bool
    @Published private(set) var isPresentingAnalystForecasts: Bool

    let stock: PortfolioStock
    let analystForecasts: [StockForecastItem]
    let sentimentItems: [StockSentimentItem]
    let earningsEstimateRows: [StockEstimateRow]

    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        isAddedToWatchlist: Bool = false,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.stock = stock
        self.isAddedToWatchlist = isAddedToWatchlist
        self.isPresentingAnalystForecasts = false
        self.dismissAction = dismissAction

        let content = Self.content(for: stock)
        analystForecasts = content.analystForecasts
        sentimentItems = content.sentimentItems
        earningsEstimateRows = content.earningsEstimateRows
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
            dismissAction: didDismissAnalystForecasts
        )
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

    func didTapMarketSentimentSeeAll() {}

    func didTapEarningsEstimatesSeeAll() {}

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
    struct Content {
        let analystForecasts: [StockForecastItem]
        let sentimentItems: [StockSentimentItem]
        let earningsEstimateRows: [StockEstimateRow]
    }

    static func content(for stock: PortfolioStock) -> Content {
        switch stock.symbol {
        case "AAPL":
            return .init(
                analystForecasts: makeForecasts(strongBuy: 12, buy: 10, hold: 6, sell: 2, strongSell: 0),
                sentimentItems: makeSentiment(bullish: 12, bearish: 4),
                earningsEstimateRows: [
                    makeEstimateRow(
                        id: "2024_actual",
                        year: "2024",
                        stageText: "ACTUAL",
                        stageColor: Color(red: 0.24, green: 0.78, blue: 0.54),
                        revenue: "$383.3B",
                        revenueDelta: "-2.1%",
                        revenueDeltaColor: Color(red: 0.89, green: 0.23, blue: 0.23),
                        eps: "$6.13",
                        epsDelta: "-1.2%",
                        epsDeltaColor: Color(red: 0.89, green: 0.23, blue: 0.23)
                    ),
                    makeEstimateRow(
                        id: "2025_actual",
                        year: "2025",
                        stageText: "ACTUAL",
                        stageColor: Color(red: 0.24, green: 0.78, blue: 0.54),
                        revenue: "$394.3B",
                        revenueDelta: "+2.9%",
                        revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32),
                        eps: "$6.57",
                        epsDelta: "+7.2%",
                        epsDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32)
                    ),
                    makeEstimateRow(
                        id: "2026_est",
                        year: "2026",
                        stageText: "EST",
                        stageColor: Color(red: 1.0, green: 0.41, blue: 0.16),
                        revenue: "$418.1B",
                        revenueDelta: nil,
                        revenueDeltaColor: nil,
                        eps: "$7.12",
                        epsDelta: nil,
                        epsDeltaColor: nil
                    ),
                    makeEstimateRow(
                        id: "2027_est",
                        year: "2027",
                        stageText: "EST",
                        stageColor: Color(red: 1.0, green: 0.41, blue: 0.16),
                        revenue: "$442.8B",
                        revenueDelta: nil,
                        revenueDeltaColor: nil,
                        eps: "$7.85",
                        epsDelta: nil,
                        epsDeltaColor: nil
                    ),
                    makeEstimateRow(
                        id: "2028_est",
                        year: "2028",
                        stageText: "EST",
                        stageColor: Color(red: 1.0, green: 0.41, blue: 0.16),
                        revenue: "$470.2B",
                        revenueDelta: nil,
                        revenueDeltaColor: nil,
                        eps: "$8.64",
                        epsDelta: nil,
                        epsDeltaColor: nil
                    )
                ]
            )
        case "MSFT":
            return .init(
                analystForecasts: makeForecasts(strongBuy: 14, buy: 9, hold: 5, sell: 1, strongSell: 0),
                sentimentItems: makeSentiment(bullish: 10, bearish: 3),
                earningsEstimateRows: [
                    makeEstimateRow(id: "2024_actual", year: "2024", stageText: "ACTUAL", stageColor: Color(red: 0.24, green: 0.78, blue: 0.54), revenue: "$245.1B", revenueDelta: "+15.7%", revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32), eps: "$11.80", epsDelta: "+22.1%", epsDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32)),
                    makeEstimateRow(id: "2025_est", year: "2025", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$272.8B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$13.22", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2026_est", year: "2026", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$298.4B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$14.66", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2027_est", year: "2027", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$324.9B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$16.25", epsDelta: nil, epsDeltaColor: nil)
                ]
            )
        case "TSLA":
            return .init(
                analystForecasts: makeForecasts(strongBuy: 7, buy: 8, hold: 11, sell: 5, strongSell: 2),
                sentimentItems: makeSentiment(bullish: 8, bearish: 9),
                earningsEstimateRows: [
                    makeEstimateRow(id: "2024_actual", year: "2024", stageText: "ACTUAL", stageColor: Color(red: 0.24, green: 0.78, blue: 0.54), revenue: "$97.7B", revenueDelta: "+3.4%", revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32), eps: "$3.12", epsDelta: "-18.4%", epsDeltaColor: Color(red: 0.89, green: 0.23, blue: 0.23)),
                    makeEstimateRow(id: "2025_est", year: "2025", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$109.4B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$3.44", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2026_est", year: "2026", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$126.8B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$4.25", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2027_est", year: "2027", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$142.3B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$5.08", epsDelta: nil, epsDeltaColor: nil)
                ]
            )
        case "NVDA":
            return .init(
                analystForecasts: makeForecasts(strongBuy: 16, buy: 12, hold: 4, sell: 1, strongSell: 0),
                sentimentItems: makeSentiment(bullish: 15, bearish: 2),
                earningsEstimateRows: [
                    makeEstimateRow(id: "2024_actual", year: "2024", stageText: "ACTUAL", stageColor: Color(red: 0.24, green: 0.78, blue: 0.54), revenue: "$130.5B", revenueDelta: "+114.2%", revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32), eps: "$12.09", epsDelta: "+131.7%", epsDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32)),
                    makeEstimateRow(id: "2025_est", year: "2025", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$164.7B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$15.01", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2026_est", year: "2026", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$189.8B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$17.24", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2027_est", year: "2027", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$208.6B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$18.83", epsDelta: nil, epsDeltaColor: nil)
                ]
            )
        case "GOOGL":
            return .init(
                analystForecasts: makeForecasts(strongBuy: 11, buy: 13, hold: 6, sell: 1, strongSell: 0),
                sentimentItems: makeSentiment(bullish: 11, bearish: 3),
                earningsEstimateRows: [
                    makeEstimateRow(id: "2024_actual", year: "2024", stageText: "ACTUAL", stageColor: Color(red: 0.24, green: 0.78, blue: 0.54), revenue: "$350.0B", revenueDelta: "+13.5%", revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32), eps: "$7.89", epsDelta: "+34.6%", epsDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32)),
                    makeEstimateRow(id: "2025_est", year: "2025", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$381.7B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$8.63", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2026_est", year: "2026", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$411.9B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$9.38", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2027_est", year: "2027", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$439.8B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$10.11", epsDelta: nil, epsDeltaColor: nil)
                ]
            )
        default:
            return .init(
                analystForecasts: makeForecasts(strongBuy: 8, buy: 10, hold: 7, sell: 2, strongSell: 0),
                sentimentItems: makeSentiment(bullish: 9, bearish: 4),
                earningsEstimateRows: [
                    makeEstimateRow(id: "2024_actual", year: "2024", stageText: "ACTUAL", stageColor: Color(red: 0.24, green: 0.78, blue: 0.54), revenue: "$120.0B", revenueDelta: "+5.1%", revenueDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32), eps: "$4.32", epsDelta: "+8.4%", epsDeltaColor: Color(red: 0.14, green: 0.72, blue: 0.32)),
                    makeEstimateRow(id: "2025_est", year: "2025", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$132.4B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$4.71", epsDelta: nil, epsDeltaColor: nil),
                    makeEstimateRow(id: "2026_est", year: "2026", stageText: "EST", stageColor: Color(red: 1.0, green: 0.41, blue: 0.16), revenue: "$145.8B", revenueDelta: nil, revenueDeltaColor: nil, eps: "$5.08", epsDelta: nil, epsDeltaColor: nil)
                ]
            )
        }
    }

    static func makeForecasts(
        strongBuy: Int,
        buy: Int,
        hold: Int,
        sell: Int,
        strongSell: Int
    ) -> [StockForecastItem] {
        [
            .init(id: "strong_buy", title: "Strong Buy", count: strongBuy, indicatorColor: Color(red: 0.14, green: 0.80, blue: 0.61), badgeForegroundColor: Color(red: 0.14, green: 0.72, blue: 0.32), badgeBackgroundColor: Color(red: 0.90, green: 0.98, blue: 0.92)),
            .init(id: "buy", title: "Buy", count: buy, indicatorColor: Color(red: 0.20, green: 0.76, blue: 0.64), badgeForegroundColor: Color(red: 0.14, green: 0.72, blue: 0.32), badgeBackgroundColor: Color(red: 0.90, green: 0.98, blue: 0.92)),
            .init(id: "hold", title: "Hold", count: hold, indicatorColor: Color(red: 0.58, green: 0.65, blue: 0.75), badgeForegroundColor: Color(red: 0.38, green: 0.45, blue: 0.55), badgeBackgroundColor: Color(red: 0.95, green: 0.96, blue: 0.98)),
            .init(id: "sell", title: "Sell", count: sell, indicatorColor: Color(red: 0.98, green: 0.55, blue: 0.60), badgeForegroundColor: Color(red: 0.89, green: 0.23, blue: 0.23), badgeBackgroundColor: Color(red: 1.0, green: 0.92, blue: 0.92)),
            .init(id: "strong_sell", title: "Strong Sell", count: strongSell, indicatorColor: Color(red: 0.96, green: 0.29, blue: 0.42), badgeForegroundColor: Color(red: 0.89, green: 0.23, blue: 0.23), badgeBackgroundColor: Color(red: 1.0, green: 0.92, blue: 0.92))
        ]
    }

    static func makeSentiment(bullish: Int, bearish: Int) -> [StockSentimentItem] {
        [
            .init(id: "bullish", title: "Bullish Signals", count: bullish, indicatorColor: Color(red: 0.14, green: 0.80, blue: 0.61), badgeForegroundColor: Color(red: 0.14, green: 0.72, blue: 0.32), badgeBackgroundColor: Color(red: 0.90, green: 0.98, blue: 0.92)),
            .init(id: "bearish", title: "Bearish Signals", count: bearish, indicatorColor: Color(red: 0.96, green: 0.29, blue: 0.42), badgeForegroundColor: Color(red: 0.89, green: 0.23, blue: 0.23), badgeBackgroundColor: Color(red: 1.0, green: 0.92, blue: 0.92))
        ]
    }

    static func makeEstimateRow(
        id: String,
        year: String,
        stageText: LocalizedStringResource,
        stageColor: Color,
        revenue: String,
        revenueDelta: String?,
        revenueDeltaColor: Color?,
        eps: String,
        epsDelta: String?,
        epsDeltaColor: Color?
    ) -> StockEstimateRow {
        StockEstimateRow(
            id: id,
            yearText: year,
            stageText: stageText,
            stageColor: stageColor,
            revenueText: revenue,
            revenueDeltaText: revenueDelta,
            revenueDeltaColor: revenueDeltaColor,
            epsText: eps,
            epsDeltaText: epsDelta,
            epsDeltaColor: epsDeltaColor
        )
    }
}
