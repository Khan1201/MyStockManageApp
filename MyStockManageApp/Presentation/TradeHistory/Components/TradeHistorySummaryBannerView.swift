import SwiftUI

struct TradeHistorySummaryBannerView: View {
    let summaryText: String

    var body: some View {
        HStack(spacing: 12) {
            Text(verbatim: summaryText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 1.0, green: 0.41, blue: 0.16))

            Spacer(minLength: 12)

            Image(systemName: "calendar")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 1.0, green: 0.41, blue: 0.16))
                .frame(width: 20, height: 20)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color(red: 1.0, green: 0.41, blue: 0.16), lineWidth: 1)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 1.0, green: 0.97, blue: 0.95))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(red: 0.93, green: 0.89, blue: 0.86))
                .frame(height: 1)
        }
    }
}
