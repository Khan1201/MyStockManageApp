import SwiftUI

struct EarningsRevenueLegendView: View {
    private static let beatEstimateTitle: LocalizedStringResource = "Beat Estimate"
    private static let partialMissTitle: LocalizedStringResource = "Partial Miss"
    private static let missedEstimateTitle: LocalizedStringResource = "Missed Estimate"
    private static let projectedTitle: LocalizedStringResource = "Projected"

    var body: some View {
        ViewThatFits {
            HStack(spacing: 22) {
                legendItem(color: EarningsRevenueQuarterState.beat.legendColor, title: Self.beatEstimateTitle)
                legendItem(color: EarningsRevenueQuarterState.partialMiss.legendColor, title: Self.partialMissTitle)
                legendItem(color: EarningsRevenueQuarterState.miss.legendColor, title: Self.missedEstimateTitle)
                legendItem(color: EarningsRevenueQuarterState.projected.legendColor, title: Self.projectedTitle)
            }

            VStack(alignment: .leading, spacing: 10) {
                legendItem(color: EarningsRevenueQuarterState.beat.legendColor, title: Self.beatEstimateTitle)
                legendItem(color: EarningsRevenueQuarterState.partialMiss.legendColor, title: Self.partialMissTitle)
                legendItem(color: EarningsRevenueQuarterState.miss.legendColor, title: Self.missedEstimateTitle)
                legendItem(color: EarningsRevenueQuarterState.projected.legendColor, title: Self.projectedTitle)
            }
        }
    }

    private func legendItem(color: Color, title: LocalizedStringResource) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Self.textColor)
        }
    }

    private static let textColor = Color(red: 0.54, green: 0.60, blue: 0.67)
}
