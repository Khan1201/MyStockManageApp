import SwiftUI

enum AnalystForecastTrend {
    case upward
    case steady
    case downward

    var symbolName: String {
        switch self {
        case .upward:
            return "chart.line.uptrend.xyaxis"
        case .steady:
            return "minus"
        case .downward:
            return "chart.line.downtrend.xyaxis"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .upward:
            return Color(red: 0.14, green: 0.79, blue: 0.50)
        case .steady:
            return Color(red: 0.53, green: 0.59, blue: 0.68)
        case .downward:
            return Color(red: 0.96, green: 0.29, blue: 0.32)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .upward:
            return Color(red: 0.91, green: 0.98, blue: 0.93)
        case .steady:
            return Color(red: 0.95, green: 0.96, blue: 0.98)
        case .downward:
            return Color(red: 1.0, green: 0.92, blue: 0.92)
        }
    }
}
