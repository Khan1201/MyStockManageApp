import SwiftUI

struct EarningsRevenueQuarterCardView: View {
    private static let revenueTitle: LocalizedStringResource = "REVENUE"
    private static let epsTitle: LocalizedStringResource = "EPS"
    private static let estimatedRevenueTitle: LocalizedStringResource = "EST. REVENUE"
    private static let estimatedEPSTitle: LocalizedStringResource = "EST. EPS"

    let item: EarningsRevenueQuarterItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: item.quarterTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.primaryColor)

                Spacer(minLength: 12)

                Text(verbatim: item.trailingStatusText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(Self.trailingTextColor)
            }

            if let statusTitle = item.state.statusTitle {
                Text(statusTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(item.state.legendColor)
            }

            HStack(alignment: .top, spacing: 28) {
                metricColumn(
                    title: isProjected ? Self.estimatedRevenueTitle : Self.revenueTitle,
                    valueText: item.revenueValueText,
                    estimateText: item.revenueEstimateText,
                    performanceText: item.revenuePerformanceText,
                    performanceColor: item.revenuePerformanceColor
                )

                metricColumn(
                    title: isProjected ? Self.estimatedEPSTitle : Self.epsTitle,
                    valueText: item.epsValueText,
                    estimateText: item.epsEstimateText,
                    performanceText: item.epsPerformanceText,
                    performanceColor: item.epsPerformanceColor
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(alignment: .leading) {
            if let accentColor = item.state.accentColor {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 14)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0.92, green: 0.93, blue: 0.95), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 4)
    }

    private func metricColumn(
        title: LocalizedStringResource,
        valueText: String,
        estimateText: String?,
        performanceText: String?,
        performanceColor: Color?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(isProjected ? Self.projectedCaptionColor : Self.captionColor)

            Text(verbatim: valueText)
                .font(.system(size: isProjected ? 26 : 30, weight: isProjected ? .semibold : .bold, design: .rounded))
                .minimumScaleFactor(0.75)
                .foregroundStyle(isProjected ? Self.projectedValueColor : Self.primaryColor)

            if let estimateText {
                Text(verbatim: estimateText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Self.secondaryTextColor)
            }

            if let performanceText, let performanceColor {
                Text(verbatim: performanceText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(performanceColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var isProjected: Bool {
        item.state == .projected
    }

    private static let primaryColor = Color(red: 0.11, green: 0.14, blue: 0.22)
    private static let captionColor = Color(red: 0.53, green: 0.60, blue: 0.70)
    private static let secondaryTextColor = Color(red: 0.66, green: 0.71, blue: 0.77)
    private static let trailingTextColor = Color(red: 0.71, green: 0.76, blue: 0.82)
    private static let projectedCaptionColor = Color(red: 0.64, green: 0.69, blue: 0.76)
    private static let projectedValueColor = Color(red: 0.42, green: 0.48, blue: 0.58)
}
