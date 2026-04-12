import SwiftUI

struct SearchResultsSectionView: View {
    let title: LocalizedStringResource
    let cancelTitle: LocalizedStringResource
    let results: [SearchResultStock]
    let cancelAction: () -> Void
    let selectionAction: (SearchResultStock) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                Spacer()

                Button(action: cancelAction) {
                    Text(cancelTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.41, blue: 0.16))
                }
                .buttonStyle(.plain)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, stock in
                        SearchResultRowView(stock: stock, action: { selectionAction(stock) })

                        if index < results.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .safeAreaPadding(.top, 6)
        }
    }
}
