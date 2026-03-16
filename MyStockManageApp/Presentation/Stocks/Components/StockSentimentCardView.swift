import SwiftUI

struct StockSentimentCardView: View {
    let timeframeTitle: LocalizedStringResource
    let items: [StockSentimentItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(timeframeTitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Self.captionColor)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(item.indicatorColor)
                            .frame(width: 7, height: 7)

                        Text(item.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Self.primaryColor)

                        Spacer()

                        Text(verbatim: "\(item.count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(item.badgeForegroundColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(item.badgeBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .padding(.vertical, 11)

                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 19)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private static let primaryColor = Color(red: 0.42, green: 0.47, blue: 0.56)
    private static let captionColor = Color(red: 0.70, green: 0.74, blue: 0.80)
}
