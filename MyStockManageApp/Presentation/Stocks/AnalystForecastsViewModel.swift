import SwiftUI

@MainActor
final class AnalystForecastsViewModel: ObservableObject {
    @Published private(set) var overviewItems: [AnalystForecastSummaryCardItem]
    @Published private(set) var forecasts: [AnalystForecastDetailItem]

    let stock: PortfolioStock

    private let fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase
    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase = .noop,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.stock = stock
        self.fetchAnalystForecastsUseCase = fetchAnalystForecastsUseCase
        self.dismissAction = dismissAction
        self.overviewItems = []
        self.forecasts = []
    }

    func loadAnalystForecasts() async {
        do {
            let content = try await fetchAnalystForecastsUseCase.execute(stock: stock)
            overviewItems = Self.makeOverviewItems(content.overview)
            forecasts = content.forecasts.map { Self.makeForecast($0, currentPrice: stock.price) }
        } catch {
            overviewItems = []
            forecasts = []
        }
    }

    func didTapBackButton() {
        dismissAction()
    }
}

private extension AnalystForecastsViewModel {
    static func makeOverviewItems(_ overview: AnalystForecastOverview) -> [AnalystForecastSummaryCardItem] {
        [
            .init(
                id: "avg_target",
                title: "AVG. TARGET",
                valueText: String(format: "$%.2f", overview.averageTarget),
                valueColor: Color(red: 0.12, green: 0.16, blue: 0.28)
            ),
            .init(
                id: "consensus",
                title: "CONSENSUS",
                valueText: recommendationText(overview.consensus),
                valueColor: recommendationColor(overview.consensus)
            ),
            .init(
                id: "analysts",
                title: "ANALYSTS",
                valueText: "\(overview.analystsCount)",
                valueColor: Color(red: 0.12, green: 0.16, blue: 0.28)
            )
        ]
    }

    static func makeForecast(
        _ forecast: AnalystForecastRecord,
        currentPrice: Double
    ) -> AnalystForecastDetailItem {
        AnalystForecastDetailItem(
            id: forecast.id,
            firmName: forecast.firmName,
            analystName: forecast.analystName,
            ratingText: recommendationText(forecast.rating),
            ratingColor: recommendationColor(forecast.rating),
            scoreText: String(format: "%.1f", forecast.score),
            dateText: forecast.dateText,
            priceTargetText: String(format: "$%.2f", forecast.priceTarget),
            priceTargetValue: forecast.priceTarget,
            trend: trend(for: forecast.priceTarget, currentPrice: currentPrice)
        )
    }

    static func recommendationText(_ recommendation: AnalystRecommendation) -> String {
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

    static func recommendationColor(_ recommendation: AnalystRecommendation) -> Color {
        switch recommendation {
        case .strongBuy, .buy:
            return Color(red: 0.14, green: 0.72, blue: 0.32)
        case .hold, .neutral:
            return Color(red: 0.49, green: 0.56, blue: 0.65)
        case .sell, .strongSell:
            return Color(red: 0.89, green: 0.23, blue: 0.23)
        }
    }

    static func trend(for target: Double, currentPrice: Double) -> AnalystForecastTrend {
        let ratio = currentPrice == 0 ? 1 : target / currentPrice

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
