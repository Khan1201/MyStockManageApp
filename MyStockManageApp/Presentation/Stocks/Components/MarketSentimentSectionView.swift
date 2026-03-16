import SwiftUI

struct MarketSentimentSectionView: View {
    let section: MarketSentimentSection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section.title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Self.sectionTitleColor)
                .tracking(1)

            VStack(spacing: 22) {
                ForEach(section.items) { item in
                    MarketSentimentRowView(item: item)
                }
            }
        }
    }

    private static let sectionTitleColor = Color(red: 0.47, green: 0.53, blue: 0.63)
}
