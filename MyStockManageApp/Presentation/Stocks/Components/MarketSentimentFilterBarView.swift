import SwiftUI

struct MarketSentimentFilterBarView: View {
    let selectedFilter: MarketSentimentFilter
    let action: (MarketSentimentFilter) -> Void

    var body: some View {
        HStack(spacing: 20) {
            ForEach(MarketSentimentFilter.allCases) { filter in
                Button {
                    action(filter)
                } label: {
                    VStack(spacing: 10) {
                        Text(filter.title)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .bold : .semibold, design: .rounded))
                            .foregroundStyle(selectedFilter == filter ? Self.selectedColor : Self.defaultColor)
                            .frame(height: 30)

                        Capsule()
                            .fill(selectedFilter == filter ? Self.selectedColor : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Self.dividerColor)
                .frame(height: 1)
        }
    }

    private static let selectedColor = Color(red: 1.0, green: 0.41, blue: 0.16)
    private static let defaultColor = Color(red: 0.56, green: 0.61, blue: 0.71)
    private static let dividerColor = Color(red: 0.92, green: 0.93, blue: 0.95)
}
