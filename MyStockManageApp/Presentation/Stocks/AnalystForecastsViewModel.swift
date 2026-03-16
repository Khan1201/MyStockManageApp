import SwiftUI

final class AnalystForecastsViewModel: ObservableObject {
    let overviewItems: [AnalystForecastSummaryCardItem]
    let forecasts: [AnalystForecastDetailItem]

    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.dismissAction = dismissAction

        let content = Self.content(for: stock)
        overviewItems = content.overviewItems
        forecasts = content.forecasts
    }

    func didTapBackButton() {
        dismissAction()
    }
}

private extension AnalystForecastsViewModel {
    struct Content {
        let overviewItems: [AnalystForecastSummaryCardItem]
        let forecasts: [AnalystForecastDetailItem]
    }

    static func content(for stock: PortfolioStock) -> Content {
        switch stock.symbol {
        case "AAPL":
            return .init(
                overviewItems: makeOverviewItems(
                    averageTarget: 202.40,
                    consensusText: "Buy",
                    consensusColor: Color(red: 1.0, green: 0.41, blue: 0.16),
                    analystsCount: 24
                ),
                forecasts: [
                    makeForecast(
                        id: "goldman_sachs",
                        firmName: "Goldman Sachs",
                        analystName: "Jane Doe",
                        ratingText: "Strong Buy",
                        ratingColor: Color(red: 0.14, green: 0.72, blue: 0.32),
                        score: 4.8,
                        dateText: "26/03/15",
                        priceTarget: 210.00,
                        trend: .upward
                    ),
                    makeForecast(
                        id: "barclays",
                        firmName: "Barclays",
                        analystName: "David Chen",
                        ratingText: "Buy",
                        ratingColor: Color(red: 0.14, green: 0.72, blue: 0.32),
                        score: 4.5,
                        dateText: "26/03/08",
                        priceTarget: 208.00,
                        trend: .upward
                    ),
                    makeForecast(
                        id: "morgan_stanley",
                        firmName: "Morgan Stanley",
                        analystName: "John Smith",
                        ratingText: "Buy",
                        ratingColor: Color(red: 0.14, green: 0.72, blue: 0.32),
                        score: 4.2,
                        dateText: "26/03/12",
                        priceTarget: 205.00,
                        trend: .upward
                    ),
                    makeForecast(
                        id: "jp_morgan",
                        firmName: "J.P. Morgan",
                        analystName: "Alice Wang",
                        ratingText: "Neutral",
                        ratingColor: Color(red: 0.49, green: 0.56, blue: 0.65),
                        score: 3.8,
                        dateText: "26/03/10",
                        priceTarget: 190.00,
                        trend: .steady
                    ),
                    makeForecast(
                        id: "bank_of_america",
                        firmName: "Bank of America",
                        analystName: "Robert Taylor",
                        ratingText: "Neutral",
                        ratingColor: Color(red: 0.49, green: 0.56, blue: 0.65),
                        score: 3.5,
                        dateText: "26/03/01",
                        priceTarget: 195.00,
                        trend: .steady
                    ),
                    makeForecast(
                        id: "ubs",
                        firmName: "UBS",
                        analystName: "Sarah Miller",
                        ratingText: "Sell",
                        ratingColor: Color(red: 0.89, green: 0.23, blue: 0.23),
                        score: 2.1,
                        dateText: "26/03/05",
                        priceTarget: 175.00,
                        trend: .downward
                    )
                ]
            )
        default:
            return makeGenericContent(for: stock)
        }
    }

    static func makeGenericContent(for stock: PortfolioStock) -> Content {
        let targetMultipliers = [1.10, 1.07, 1.05, 1.00, 0.98, 0.92]
        let scores = [4.7, 4.4, 4.1, 3.7, 3.4, 2.3]
        let firms = [
            ("goldman_sachs", "Goldman Sachs", "Taylor Reed"),
            ("barclays", "Barclays", "Jordan Lee"),
            ("morgan_stanley", "Morgan Stanley", "Sam Patel"),
            ("jp_morgan", "J.P. Morgan", "Casey Kim"),
            ("bank_of_america", "Bank of America", "Alex Brown"),
            ("ubs", "UBS", "Morgan Diaz")
        ]
        let dates = ["26/03/15", "26/03/12", "26/03/10", "26/03/08", "26/03/05", "26/03/01"]

        let forecasts = firms.enumerated().map { index, firm in
            let target = stock.price * targetMultipliers[index]
            let score = scores[index]
            let rating = ratingPresentation(for: score)

            return makeForecast(
                id: firm.0,
                firmName: firm.1,
                analystName: firm.2,
                ratingText: rating.text,
                ratingColor: rating.color,
                score: score,
                dateText: dates[index],
                priceTarget: target,
                trend: trend(for: target, currentPrice: stock.price)
            )
        }

        let averageTarget = forecasts
            .map(\.priceTargetValue)
            .reduce(0, +) / Double(forecasts.count)
        let averageScore = scores.reduce(0, +) / Double(scores.count)
        let consensus = ratingPresentation(for: averageScore)

        return .init(
            overviewItems: makeOverviewItems(
                averageTarget: averageTarget,
                consensusText: consensus.text,
                consensusColor: consensus.color,
                analystsCount: 24
            ),
            forecasts: forecasts
        )
    }

    static func makeOverviewItems(
        averageTarget: Double,
        consensusText: LocalizedStringResource,
        consensusColor: Color,
        analystsCount: Int
    ) -> [AnalystForecastSummaryCardItem] {
        [
            .init(
                id: "avg_target",
                title: "AVG. TARGET",
                valueText: currencyText(for: averageTarget),
                valueColor: Color(red: 0.12, green: 0.16, blue: 0.28)
            ),
            .init(
                id: "consensus",
                title: "CONSENSUS",
                valueText: String(localized: consensusText),
                valueColor: consensusColor
            ),
            .init(
                id: "analysts",
                title: "ANALYSTS",
                valueText: "\(analystsCount)",
                valueColor: Color(red: 0.12, green: 0.16, blue: 0.28)
            )
        ]
    }

    static func makeForecast(
        id: String,
        firmName: String,
        analystName: String,
        ratingText: LocalizedStringResource,
        ratingColor: Color,
        score: Double,
        dateText: String,
        priceTarget: Double,
        trend: AnalystForecastTrend
    ) -> AnalystForecastDetailItem {
        AnalystForecastDetailItem(
            id: id,
            firmName: firmName,
            analystName: analystName,
            ratingText: ratingText,
            ratingColor: ratingColor,
            scoreText: String(format: "%.1f", score),
            dateText: dateText,
            priceTargetText: currencyText(for: priceTarget),
            priceTargetValue: priceTarget,
            trend: trend
        )
    }

    static func currencyText(for value: Double) -> String {
        String(format: "$%.2f", value)
    }

    static func ratingPresentation(for score: Double) -> (text: LocalizedStringResource, color: Color) {
        switch score {
        case 4.6...:
            return ("Strong Buy", Color(red: 0.14, green: 0.72, blue: 0.32))
        case 4.0..<4.6:
            return ("Buy", Color(red: 0.14, green: 0.72, blue: 0.32))
        case 3.0..<4.0:
            return ("Neutral", Color(red: 0.49, green: 0.56, blue: 0.65))
        default:
            return ("Sell", Color(red: 0.89, green: 0.23, blue: 0.23))
        }
    }

    static func trend(for target: Double, currentPrice: Double) -> AnalystForecastTrend {
        let ratio = currentPrice == 0 ? 0 : target / currentPrice

        switch ratio {
        case let value where value > 1.02:
            return .upward
        case let value where value < 0.98:
            return .downward
        default:
            return .steady
        }
    }
}
