import SwiftUI

struct StockEarningsEstimatesCardView: View {
    private static let yearTitle: LocalizedStringResource = "YEAR"
    private static let revenueTitle: LocalizedStringResource = "REVENUE"
    private static let epsTitle: LocalizedStringResource = "EPS"

    let rows: [StockEstimateRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 18) {
                Text(Self.yearTitle)
                    .frame(width: 56, alignment: .leading)

                Text(Self.revenueTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(Self.epsTitle)
                    .frame(width: 84, alignment: .leading)
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Self.captionColor)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    HStack(alignment: .top, spacing: 18) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(verbatim: row.yearText)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Self.primaryColor)

                            Text(row.stageText)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(row.stageColor)
                        }
                        .frame(width: 56, alignment: .leading)

                        metricColumn(
                            valueText: row.revenueText,
                            deltaText: row.revenueDeltaText,
                            deltaColor: row.revenueDeltaColor
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)

                        metricColumn(
                            valueText: row.epsText,
                            deltaText: row.epsDeltaText,
                            deltaColor: row.epsDeltaColor
                        )
                        .frame(width: 84, alignment: .leading)
                    }
                    .padding(.vertical, 12)

                    if index < rows.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func metricColumn(
        valueText: String,
        deltaText: String?,
        deltaColor: Color?
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(verbatim: valueText)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Self.primaryColor)

            if let deltaText, let deltaColor {
                Text(verbatim: deltaText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(deltaColor)
            }
        }
    }

    private static let primaryColor = Color(red: 0.36, green: 0.42, blue: 0.50)
    private static let captionColor = Color(red: 0.70, green: 0.74, blue: 0.80)
}
