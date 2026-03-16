import SwiftUI

struct AnalystForecastRowView: View {
    private static let priceTargetTitle: LocalizedStringResource = "Price Target"

    let item: AnalystForecastDetailItem

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(item.trend.backgroundColor)
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: item.trend.symbolName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(item.trend.foregroundColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: item.firmName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.primaryColor)

                HStack(spacing: 4) {
                    Text(verbatim: item.analystName)
                        .foregroundStyle(Self.secondaryColor)

                    Text(verbatim: "-")
                        .foregroundStyle(Self.secondaryColor)

                    Text(item.ratingText)
                        .foregroundStyle(item.ratingColor)

                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Self.starColor)

                    Text(verbatim: item.scoreText)
                        .foregroundStyle(Self.secondaryColor)
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Text(verbatim: item.dateText)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Self.tertiaryColor)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 4) {
                Text(verbatim: item.priceTargetText)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.primaryColor)

                Text(Self.priceTargetTitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Self.tertiaryColor)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    private static let primaryColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let secondaryColor = Color(red: 0.53, green: 0.59, blue: 0.68)
    private static let tertiaryColor = Color(red: 0.70, green: 0.73, blue: 0.78)
    private static let starColor = Color(red: 0.98, green: 0.74, blue: 0.20)
}
