import SwiftUI

struct AnalystForecastSummaryCardView: View {
    let item: AnalystForecastSummaryCardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.4)
                .foregroundStyle(Self.subtitleColor)

            Text(verbatim: item.valueText)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(item.valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.025), radius: 10, y: 5)
    }

    private static let subtitleColor = Color(red: 0.53, green: 0.59, blue: 0.68)
}
