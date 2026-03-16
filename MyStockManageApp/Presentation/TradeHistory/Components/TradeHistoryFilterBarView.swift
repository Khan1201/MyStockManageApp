import SwiftUI

struct TradeHistoryFilterBarView: View {
    let selectedFilter: TradeHistoryFilter
    let selectionAction: (TradeHistoryFilter) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TradeHistoryFilter.allCases) { filter in
                Button {
                    selectionAction(filter)
                } label: {
                    VStack(spacing: 12) {
                        Text(filter.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(filter == selectedFilter ? Self.selectedColor : Self.defaultColor)
                            .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(filter == selectedFilter ? Self.selectedColor : .clear)
                            .frame(height: 2)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 6)
        .background(.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(red: 0.90, green: 0.92, blue: 0.96))
                .frame(height: 1)
        }
    }

    private static let selectedColor = Color(red: 1.0, green: 0.41, blue: 0.16)
    private static let defaultColor = Color(red: 0.47, green: 0.52, blue: 0.61)
}
