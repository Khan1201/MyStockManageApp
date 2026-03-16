import SwiftUI

struct MarketSentimentRowView: View {
    let item: MarketSentimentItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.signal.trend.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(item.signal.trend.foregroundColor)
                .frame(width: 36, height: 36)
                .background(item.signal.trend.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: item.headline)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Self.headlineColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                HStack(spacing: 8) {
                    Text(item.signal.title)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(item.signal.badgeForegroundColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(item.signal.badgeBackgroundColor)
                        .clipShape(Capsule())

                    Text(verbatim: "\(item.sourceName) • \(item.publishedAtText)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Self.metadataColor)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Self.chevronColor)
                .padding(.top, 10)
        }
    }

    private static let headlineColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let metadataColor = Color(red: 0.56, green: 0.61, blue: 0.71)
    private static let chevronColor = Color(red: 0.69, green: 0.74, blue: 0.82)
}
