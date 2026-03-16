import SwiftUI

struct StocksTabContainerView: View {
    @StateObject private var viewModel: StocksTabContainerViewModel
    @StateObject private var stocksViewModel: StocksViewModel
    @StateObject private var tradeHistoryViewModel: TradeHistoryViewModel

    init(
        viewModel: StocksTabContainerViewModel = StocksTabContainerViewModel(),
        stocksViewModel: StocksViewModel = StocksViewModel(),
        tradeHistoryViewModel: TradeHistoryViewModel = TradeHistoryViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _stocksViewModel = StateObject(wrappedValue: stocksViewModel)
        _tradeHistoryViewModel = StateObject(wrappedValue: tradeHistoryViewModel)
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            contentView
        }
        .accessibilityIdentifier("stocks_tab_container_view")
        .overlay(alignment: .bottom) {
            BottomTabBar(
                selectedTab: viewModel.selectedTab,
                selectionAction: viewModel.didSelectTab
            )
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedTab {
        case .home:
            StocksView(viewModel: stocksViewModel)
        case .history:
            TradeHistoryView(viewModel: tradeHistoryViewModel)
        case .rules:
            StocksView(viewModel: stocksViewModel)
        case .quotes:
            StocksView(viewModel: stocksViewModel)
        }
    }
}

struct StocksTabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        StocksTabContainerView()
    }
}
