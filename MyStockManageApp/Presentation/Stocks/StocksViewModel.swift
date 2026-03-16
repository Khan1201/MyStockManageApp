import SwiftUI

final class StocksViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var selectedTab: StocksTab = .home
    @Published private(set) var isEditingPortfolio = false
    @Published private(set) var selectedPortfolioStock: PortfolioStock?
    @Published private(set) var selectedSearchResultStock: SearchResultStock?

    private let portfolio: [PortfolioStock]
    private let searchableStocks: [SearchResultStock]

    init(
        portfolio: [PortfolioStock] = StocksViewModel.defaultPortfolio,
        searchableStocks: [SearchResultStock] = StocksViewModel.defaultSearchableStocks
    ) {
        self.portfolio = portfolio
        self.searchableStocks = searchableStocks
    }

    var displayedStocks: [PortfolioStock] {
        let trimmedQuery = normalizedSearchText
        guard trimmedQuery.isEmpty == false else {
            return portfolio
        }

        let query = trimmedQuery.localizedLowercase
        return portfolio.filter { stock in
            stock.symbol.localizedLowercase.contains(query) ||
            stock.companyName.localizedLowercase.contains(query)
        }
    }

    var isShowingSearchResults: Bool {
        normalizedSearchText.isEmpty == false
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

    func didSelectTab(_ tab: StocksTab) {
        selectedTab = tab
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

    private var normalizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension StocksViewModel {
    static let defaultPortfolio: [PortfolioStock] = [
        PortfolioStock(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: 1.24,
            logoStyle: .apple
        ),
        PortfolioStock(
            symbol: "MSFT",
            companyName: "Microsoft Corp",
            price: 415.32,
            changePercent: -0.45,
            logoStyle: .microsoft
        ),
        PortfolioStock(
            symbol: "TSLA",
            companyName: "Tesla, Inc.",
            price: 175.22,
            changePercent: 2.15,
            logoStyle: .tesla
        ),
        PortfolioStock(
            symbol: "NVDA",
            companyName: "NVIDIA Corp",
            price: 875.28,
            changePercent: 0.82,
            logoStyle: .nvidia
        ),
        PortfolioStock(
            symbol: "GOOGL",
            companyName: "Alphabet Inc.",
            price: 142.65,
            changePercent: -1.12,
            logoStyle: .google
        )
    ]

    static let defaultSearchableStocks: [SearchResultStock] = [
        SearchResultStock(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            logoStyle: .apple
        ),
        SearchResultStock(
            symbol: "AMZN",
            companyName: "Amazon.com, Inc.",
            logoStyle: .amazon
        ),
        SearchResultStock(
            symbol: "AMD",
            companyName: "Advanced Micro Devices, Inc.",
            logoStyle: .amd
        ),
        SearchResultStock(
            symbol: "ADBE",
            companyName: "Adobe Inc.",
            logoStyle: .adobe
        )
    ]
}
