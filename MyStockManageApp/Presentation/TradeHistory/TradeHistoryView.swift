import SwiftUI

struct TradeHistoryView: View {
    private static let screenTitle: LocalizedStringResource = "Trade History"

    @ObservedObject var viewModel: TradeHistoryViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Self.screenTitle)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    TradeHistoryFilterBarView(
                        selectedFilter: viewModel.selectedFilter,
                        selectionAction: viewModel.didSelectFilter
                    )

                    TradeHistorySummaryBannerView(summaryText: viewModel.summaryText)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.displayedSections) { section in
                                Text(verbatim: section.title)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.57, green: 0.62, blue: 0.71))
                                    .padding(.top, 18)
                                    .padding(.bottom, 8)

                                ForEach(Array(section.transactions.enumerated()), id: \.element.id) { index, transaction in
                                    TradeHistoryTransactionRowView(
                                        transaction: transaction,
                                        showsDivider: index < section.transactions.count - 1
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 140)
                    }
                }
            .scrollIndicators(.hidden)

            TradeHistoryFloatingActionButton(action: viewModel.didTapAddTradeButton)
                .padding(.trailing, 16)
                .padding(.bottom, 96)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white)
        .fullScreenCover(item: presentedTradeEditorBinding) { tradeEditorViewModel in
            TradeEditorView(viewModel: tradeEditorViewModel)
        }
        .task {
            await viewModel.loadTradeHistory()
        }
    }

    private var presentedTradeEditorBinding: Binding<TradeEditorViewModel?> {
        Binding(
            get: { viewModel.tradeEditorViewModel },
            set: { tradeEditorViewModel in
                guard tradeEditorViewModel == nil else {
                    return
                }

                viewModel.didDismissTradeEditor()
            }
        )
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView(
            viewModel: AppDependencyContainer.preview().makeTradeHistoryViewModel()
        )
    }
}
