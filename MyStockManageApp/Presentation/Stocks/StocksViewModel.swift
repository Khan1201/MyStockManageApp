import SwiftUI

@MainActor
final class StocksViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var isEditingPortfolio = false
    @Published private(set) var selectedPortfolioStock: PortfolioStock?
    @Published private(set) var selectedSearchResultStock: SearchResultStock?
    @Published private(set) var portfolio: [PortfolioStock]
    @Published private(set) var searchableStocks: [SearchResultStock]

    private let fetchStocksOverviewUseCase: FetchStocksOverviewUseCase
    private let stockDetailsViewModelBuilder: (PortfolioStock, @escaping () -> Void) -> StockDetailsViewModel

    init(
        portfolio: [PortfolioStock] = [],
        searchableStocks: [SearchResultStock] = [],
        fetchStocksOverviewUseCase: FetchStocksOverviewUseCase = .noop,
        stockDetailsViewModelBuilder: ((PortfolioStock, @escaping () -> Void) -> StockDetailsViewModel)? = nil
    ) {
        self.portfolio = portfolio
        self.searchableStocks = searchableStocks
        self.fetchStocksOverviewUseCase = fetchStocksOverviewUseCase
        self.stockDetailsViewModelBuilder = stockDetailsViewModelBuilder ?? { stock, dismissAction in
            StockDetailsViewModel(stock: stock, dismissAction: dismissAction)
        }
    }

    var displayedStocks: [PortfolioStock] {
        let trimmedQuery = normalizedSearchText
        guard !trimmedQuery.isEmpty else {
            return portfolio
        }

        let query = trimmedQuery.localizedLowercase
        return portfolio.filter { stock in
            stock.symbol.localizedLowercase.contains(query) ||
            stock.companyName.localizedLowercase.contains(query)
        }
    }

    var isShowingSearchResults: Bool {
        !normalizedSearchText.isEmpty
    }

    var searchResults: [SearchResultStock] {
        guard isShowingSearchResults else {
            return []
        }

        let query = normalizedSearchText.localizedLowercase
        return searchableStocks.filter { stock in
            stock.symbol.localizedLowercase.contains(query) ||
            stock.companyName.localizedLowercase.contains(query)
        }
    }

    func loadStocksOverview() async {
        do {
            let overview = try await fetchStocksOverviewUseCase.execute()
            portfolio = overview.portfolio
            searchableStocks = overview.searchableStocks
        } catch {
            portfolio = []
            searchableStocks = []
        }
    }

    func didTapClearSearch() {
        searchText = ""
    }

    func didTapEditButton() {
        isEditingPortfolio = true
    }

    func didSelectPortfolioStock(_ stock: PortfolioStock) {
        selectedPortfolioStock = stock
    }

    func didDismissPortfolioStockDetails() {
        selectedPortfolioStock = nil
    }

    func didSelectSearchResultStock(_ stock: SearchResultStock) {
        selectedSearchResultStock = stock
    }

    func makeStockDetailsViewModel(for stock: PortfolioStock) -> StockDetailsViewModel {
        stockDetailsViewModelBuilder(stock) { [weak self] in
            self?.didDismissPortfolioStockDetails()
        }
    }

    private var normalizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
