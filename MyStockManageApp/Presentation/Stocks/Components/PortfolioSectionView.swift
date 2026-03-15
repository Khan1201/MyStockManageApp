import SwiftUI

struct PortfolioSectionView: View {
    let title: LocalizedStringResource
    let editTitle: LocalizedStringResource
    let stocks: [PortfolioStock]
    let editAction: () -> Void
    let selectionAction: (PortfolioStock) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                Spacer()

                Button(action: editAction) {
                    Text(editTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.41, blue: 0.16))
                }
                .buttonStyle(.plain)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(stocks.enumerated()), id: \.element.id) { index, stock in
                        PortfolioRowView(stock: stock, action: { selectionAction(stock) })

                        if index < stocks.count - 1 {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
            }
            .safeAreaPadding(.top, 6)
        }
    }
}
