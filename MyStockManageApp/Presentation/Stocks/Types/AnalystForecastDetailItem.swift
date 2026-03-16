import SwiftUI

struct AnalystForecastDetailItem: Identifiable {
    let id: String
    let firmName: String
    let analystName: String
    let ratingText: LocalizedStringResource
    let ratingColor: Color
    let scoreText: String
    let dateText: String
    let priceTargetText: String
    let priceTargetValue: Double
    let trend: AnalystForecastTrend
}
