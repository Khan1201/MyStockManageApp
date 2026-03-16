import SwiftUI

struct StocksView: View {
    private static let screenTitle: LocalizedStringResource = "Stocks"
    private static let searchPlaceholder: LocalizedStringResource = "Search symbols or companies"
    private static let portfolioTitle: LocalizedStringResource = "My Portfolio"
    private static let editTitle: LocalizedStringResource = "Edit"
    private static let searchResultsTitle: LocalizedStringResource = "Search Results"
    private static let cancelTitle: LocalizedStringResource = "Cancel"
    
    @StateObject private var viewModel: StocksViewModel
    
    init(viewModel: StocksViewModel = StocksViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 26) {
                Text(Self.screenTitle)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                
                SearchBarView(
                    text: $viewModel.searchText,
                    placeholder: Self.searchPlaceholder,
                    clearAction: viewModel.didTapClearSearch
                )
                
                if viewModel.isShowingSearchResults {
                    SearchResultsSectionView(
                        title: Self.searchResultsTitle,
                        cancelTitle: Self.cancelTitle,
                        results: viewModel.searchResults,
                        cancelAction: viewModel.didTapClearSearch,
                        selectionAction: viewModel.didSelectSearchResultStock
                    )
                } else {
                    PortfolioSectionView(
                        title: Self.portfolioTitle,
                        editTitle: Self.editTitle,
                        stocks: viewModel.displayedStocks,
                        editAction: viewModel.didTapEditButton,
                        selectionAction: viewModel.didSelectPortfolioStock
                    )
                }
            }
            .padding(.bottom, 108)
                        
            Spacer()
        }
        .padding(.horizontal, 16)
        .accessibilityIdentifier("stocks_root_view")
        .overlay(alignment: .bottom) {
            BottomTabBar(
                selectedTab: viewModel.selectedTab,
                selectionAction: viewModel.didSelectTab
            )
        }
        .fullScreenCover(item: selectedPortfolioStockBinding) { stock in
            StockDetailsView(
                viewModel: StockDetailsViewModel(
                    stock: stock,
                    dismissAction: viewModel.didDismissPortfolioStockDetails
                )
            )
        }
    }

    private var selectedPortfolioStockBinding: Binding<PortfolioStock?> {
        Binding(
            get: { viewModel.selectedPortfolioStock },
            set: { stock in
                guard let stock else {
                    viewModel.didDismissPortfolioStockDetails()
                    return
                }

                viewModel.didSelectPortfolioStock(stock)
            }
        )
    }
}

struct StocksView_Previews: PreviewProvider {
    static var previews: some View {
        StocksView()
    }
}
