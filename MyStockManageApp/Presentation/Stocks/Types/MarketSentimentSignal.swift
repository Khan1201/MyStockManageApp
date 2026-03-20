import SwiftUI

typealias MarketSentimentSignal = StockMarketSignal

extension MarketSentimentSignal {
    var title: LocalizedStringResource {
        switch self {
        case .bullish:
            return "Bullish"
        case .bearish:
            return "Bearish"
        }
    }

    var trend: AnalystForecastTrend {
        switch self {
        case .bullish:
            return .upward
        case .bearish:
            return .downward
        }
    }

    var badgeForegroundColor: Color {
        switch self {
        case .bullish:
            return Color(red: 0.14, green: 0.72, blue: 0.32)
        case .bearish:
            return Color(red: 0.89, green: 0.23, blue: 0.23)
        }
    }

    var badgeBackgroundColor: Color {
        trend.backgroundColor
    }
}
