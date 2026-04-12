import SwiftUI

@MainActor
final class StocksViewModel: ObservableObject {
    @Published var searchText = "" {
        didSet {
            handleSearchTextChange()
        }
    }
    @Published private(set) var isEditingPortfolio = false
    @Published private(set) var selectedPortfolioStock: PortfolioStock?
    @Published private(set) var selectedSearchResultDetailsStock: PortfolioStock?
    @Published private(set) var portfolio: [PortfolioStock]
    @Published private(set) var searchResults: [SearchResultStock]
    @Published private(set) var debouncedSearchText = ""

    private let fetchStocksOverviewUseCase: FetchStocksOverviewUseCase
    private let searchStocksUseCase: SearchStocksUseCase
    private let fetchStockUseCase: FetchStockUseCase
    private let stockDetailsViewModelBuilder: (PortfolioStock, @escaping () -> Void) -> StockDetailsViewModel
    private let searchDebounceNanoseconds: UInt64
    private var searchResultsUpdateTask: Task<Void, Never>?
    private var searchResultSelectionTask: Task<Void, Never>?

    init(
        portfolio: [PortfolioStock] = [],
        searchResults: [SearchResultStock] = [],
        fetchStocksOverviewUseCase: FetchStocksOverviewUseCase = .noop,
        searchStocksUseCase: SearchStocksUseCase = .noop,
        fetchStockUseCase: FetchStockUseCase = .noop,
        stockDetailsViewModelBuilder: ((PortfolioStock, @escaping () -> Void) -> StockDetailsViewModel)? = nil,
        searchDebounceNanoseconds: UInt64 = 1_000_000_000
    ) {
        self.portfolio = portfolio
        self.searchResults = searchResults
        self.fetchStocksOverviewUseCase = fetchStocksOverviewUseCase
        self.searchStocksUseCase = searchStocksUseCase
        self.fetchStockUseCase = fetchStockUseCase
        self.stockDetailsViewModelBuilder = stockDetailsViewModelBuilder ?? { stock, dismissAction in
            StockDetailsViewModel(stock: stock, dismissAction: dismissAction)
        }
        self.searchDebounceNanoseconds = searchDebounceNanoseconds
    }

    deinit {
        searchResultsUpdateTask?.cancel()
        searchResultSelectionTask?.cancel()
    }

    var displayedStocks: [PortfolioStock] {
        portfolio
    }

    var isShowingSearchResults: Bool {
        !normalizedSearchText.isEmpty
    }

    func loadStocksOverview() async {
        do {
            let overview = try await fetchStocksOverviewUseCase.execute()
            portfolio = overview.portfolio
        } catch {
            portfolio = []
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
        searchResultSelectionTask?.cancel()
        searchResultSelectionTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let stockDetails = try await fetchStockUseCase.execute(symbol: stock.symbol)
                guard !Task.isCancelled else {
                    return
                }

                selectedSearchResultDetailsStock = stockDetails
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                selectedSearchResultDetailsStock = nil
            }
        }
    }

    func didDismissSearchResultStockDetails() {
        selectedSearchResultDetailsStock = nil
    }

    func makeStockDetailsViewModel(for stock: PortfolioStock) -> StockDetailsViewModel {
        stockDetailsViewModelBuilder(stock) { [weak self] in
            self?.didDismissPortfolioStockDetails()
        }
    }

    func makeSearchResultStockDetailsViewModel(for stock: PortfolioStock) -> StockDetailsViewModel {
        stockDetailsViewModelBuilder(stock) { [weak self] in
            self?.didDismissSearchResultStockDetails()
        }
    }

    private var normalizedSearchText: String {
        Self.searchComparableText(from: debouncedSearchText)
    }

    private func handleSearchTextChange() {
        let sanitizedSearchText = Self.searchTextWithoutWhitespace(searchText)
        guard sanitizedSearchText == searchText else {
            searchText = sanitizedSearchText
            return
        }

        scheduleSearchResultsUpdate(for: sanitizedSearchText)
    }

    private func scheduleSearchResultsUpdate(for searchText: String) {
        searchResultsUpdateTask?.cancel()
        debouncedSearchText = ""
        searchResults = []

        guard !searchText.isEmpty else {
            return
        }

        guard searchDebounceNanoseconds > 0 else {
            searchResultsUpdateTask = Task { [weak self] in
                await self?.loadSearchResults(for: searchText)
            }
            return
        }

        let delay = searchDebounceNanoseconds
        searchResultsUpdateTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: delay)
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            await self?.loadSearchResults(for: searchText)
        }
    }

    private func loadSearchResults(for searchText: String) async {
        do {
            let results = try await searchStocksUseCase.execute(query: searchText)
            guard !Task.isCancelled, self.searchText == searchText else {
                return
            }

            debouncedSearchText = searchText
            searchResults = results
        } catch {
            guard !Task.isCancelled, self.searchText == searchText else {
                return
            }

            debouncedSearchText = searchText
            searchResults = []
        }
    }

    private static func searchTextWithoutWhitespace(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).joined()
    }

    private static func searchComparableText(from text: String) -> String {
        searchTextWithoutWhitespace(text).localizedLowercase
    }
}
