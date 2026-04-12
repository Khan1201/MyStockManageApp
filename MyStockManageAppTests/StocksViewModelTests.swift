import XCTest
@testable import MyStockManageApp

@MainActor
final class StocksViewModelTests: XCTestCase {
    func testLoadStocksOverviewUpdatesPortfolio() async {
        let sut = makeSUT(
            fetchStocksOverviewUseCase: FetchStocksOverviewUseCase(
                operation: {
                    StocksOverview(portfolio: self.makePortfolio())
                }
            )
        )

        await sut.loadStocksOverview()

        XCTAssertEqual(sut.displayedStocks.map(\.symbol), ["AAPL", "MSFT", "TSLA"])
    }

    func testSearchResultsAreLoadedFromUseCase() async throws {
        let sut = makeSUT(searchResults: makeSearchResults())

        sut.searchText = "a"
        try await waitForViewModelTasks()

        XCTAssertTrue(sut.isShowingSearchResults)
        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AAPL", "AMZN", "AMD", "ADBE", "TSLA"])
    }

    func testSearchTextRemovesWhitespaceBeforeSearching() async throws {
        let querySpy = SearchQuerySpy()
        let sut = makeSUT(
            searchStocksUseCase: SearchStocksUseCase(
                operation: { query in
                    await querySpy.record(query)
                    return [self.makeSearchResults()[2]]
                }
            )
        )

        sut.searchText = "a m d"
        try await waitForViewModelTasks()

        let recordedQueries = await querySpy.queriesSnapshot()
        XCTAssertEqual(sut.searchText, "amd")
        XCTAssertEqual(recordedQueries, ["amd"])
        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AMD"])
    }

    func testSearchResultsAppearAfterDebounceDelay() async throws {
        let sut = StocksViewModel(
            searchStocksUseCase: SearchStocksUseCase(
                operation: { _ in [self.makeSearchResults()[2]] }
            ),
            searchDebounceNanoseconds: 20_000_000
        )

        sut.searchText = "amd"

        XCTAssertFalse(sut.isShowingSearchResults)
        XCTAssertTrue(sut.searchResults.isEmpty)

        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(sut.isShowingSearchResults)
        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AMD"])
    }

    func testDidTapClearSearchResetsQueryAndHidesSearchResults() async throws {
        let sut = makeSUT(searchResults: makeSearchResults())

        sut.searchText = "amd"
        try await waitForViewModelTasks()

        XCTAssertTrue(sut.isShowingSearchResults)
        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AMD"])

        sut.didTapClearSearch()

        XCTAssertEqual(sut.searchText, "")
        XCTAssertFalse(sut.isShowingSearchResults)
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func testDidTapEditButtonMarksEditingState() {
        let sut = makeSUT(portfolio: makePortfolio())

        XCTAssertFalse(sut.isEditingPortfolio)

        sut.didTapEditButton()

        XCTAssertTrue(sut.isEditingPortfolio)
    }

    func testDidSelectPortfolioStockStoresSelection() {
        let sut = makeSUT(portfolio: makePortfolio())
        let stock = makePortfolio()[1]

        sut.didSelectPortfolioStock(stock)

        XCTAssertEqual(sut.selectedPortfolioStock, stock)
    }

    func testDidDismissPortfolioStockDetailsClearsSelection() {
        let sut = makeSUT(portfolio: makePortfolio())

        sut.didSelectPortfolioStock(makePortfolio()[0])
        XCTAssertNotNil(sut.selectedPortfolioStock)

        sut.didDismissPortfolioStockDetails()

        XCTAssertNil(sut.selectedPortfolioStock)
    }

    func testDidSelectSearchResultStockLoadsStockDetails() async throws {
        let searchResult = makeSearchResults()[2]
        let expectedStock = makeSearchResultDetailsStock()
        let sut = makeSUT(
            fetchStockUseCase: FetchStockUseCase(
                operation: { symbol in
                    XCTAssertEqual(symbol, searchResult.symbol)
                    return expectedStock
                }
            )
        )

        sut.didSelectSearchResultStock(searchResult)
        try await waitForViewModelTasks()

        XCTAssertEqual(sut.selectedSearchResultDetailsStock, expectedStock)
    }

    func testDidDismissSearchResultStockDetailsClearsSelection() async throws {
        let sut = makeSUT(
            fetchStockUseCase: FetchStockUseCase(
                operation: { _ in self.makeSearchResultDetailsStock() }
            )
        )

        sut.didSelectSearchResultStock(makeSearchResults()[2])
        try await waitForViewModelTasks()
        XCTAssertNotNil(sut.selectedSearchResultDetailsStock)

        sut.didDismissSearchResultStockDetails()

        XCTAssertNil(sut.selectedSearchResultDetailsStock)
    }

    func testMakeStockDetailsViewModelUsesInjectedBuilder() {
        let stock = makePortfolio()[0]
        let expectedViewModel = StockDetailsViewModel(stock: stock)
        let sut = makeSUT(
            portfolio: makePortfolio(),
            stockDetailsViewModelBuilder: { _, _ in expectedViewModel }
        )

        let producedViewModel = sut.makeStockDetailsViewModel(for: stock)

        XCTAssertTrue(producedViewModel === expectedViewModel)
    }

    func testMakeSearchResultStockDetailsViewModelUsesInjectedBuilder() {
        let stock = makeSearchResultDetailsStock()
        let expectedViewModel = StockDetailsViewModel(stock: stock)
        let sut = makeSUT(
            stockDetailsViewModelBuilder: { _, _ in expectedViewModel }
        )

        let producedViewModel = sut.makeSearchResultStockDetailsViewModel(for: stock)

        XCTAssertTrue(producedViewModel === expectedViewModel)
    }

    func testPortfolioStockProvidesFormattedDisplayValues() {
        let stock = PortfolioStock(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: -1.24
        )

        XCTAssertEqual(stock.priceText, "$189.43")
        XCTAssertEqual(stock.changeText, "-1.24%")
        XCTAssertEqual(stock.changeDirection, .loss)
    }

    private func makeSUT(
        portfolio: [PortfolioStock] = [],
        searchResults: [SearchResultStock] = [],
        fetchStocksOverviewUseCase: FetchStocksOverviewUseCase = .noop,
        searchStocksUseCase: SearchStocksUseCase? = nil,
        fetchStockUseCase: FetchStockUseCase = .noop,
        stockDetailsViewModelBuilder: ((PortfolioStock, @escaping () -> Void) -> StockDetailsViewModel)? = nil
    ) -> StocksViewModel {
        StocksViewModel(
            portfolio: portfolio,
            searchResults: [],
            fetchStocksOverviewUseCase: fetchStocksOverviewUseCase,
            searchStocksUseCase: searchStocksUseCase ?? SearchStocksUseCase(
                operation: { query in
                    searchResults.filter { stock in
                        stock.symbol.localizedCaseInsensitiveContains(query) ||
                        stock.companyName.localizedCaseInsensitiveContains(query)
                    }
                }
            ),
            fetchStockUseCase: fetchStockUseCase,
            stockDetailsViewModelBuilder: stockDetailsViewModelBuilder,
            searchDebounceNanoseconds: 0
        )
    }

    private func waitForViewModelTasks() async throws {
        try await Task.sleep(nanoseconds: 20_000_000)
    }

    private func makePortfolio() -> [PortfolioStock] {
        [
            .init(symbol: "AAPL", companyName: "Apple Inc.", price: 189.43, changePercent: 1.24),
            .init(symbol: "MSFT", companyName: "Microsoft Corp", price: 415.32, changePercent: -0.45),
            .init(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15)
        ]
    }

    private func makeSearchResults() -> [SearchResultStock] {
        [
            .init(symbol: "AAPL", displaySymbol: "AAPL", companyName: "Apple Inc.", type: "Common Stock"),
            .init(symbol: "AMZN", displaySymbol: "AMZN", companyName: "Amazon.com, Inc.", type: "Common Stock"),
            .init(symbol: "AMD", displaySymbol: "AMD", companyName: "Advanced Micro Devices, Inc.", type: "Common Stock"),
            .init(symbol: "ADBE", displaySymbol: "ADBE", companyName: "Adobe Inc.", type: "Common Stock"),
            .init(symbol: "MSFT", displaySymbol: "MSFT", companyName: "Microsoft Corp", type: "Common Stock"),
            .init(symbol: "TSLA", displaySymbol: "TSLA", companyName: "Tesla, Inc.", type: "Common Stock")
        ]
    }

    private func makeSearchResultDetailsStock() -> PortfolioStock {
        PortfolioStock(
            symbol: "AMD",
            companyName: "Advanced Micro Devices, Inc.",
            price: 142.10,
            changePercent: -0.78
        )
    }
}

private actor SearchQuerySpy {
    private var queries: [String] = []

    func record(_ query: String) {
        queries.append(query)
    }

    func queriesSnapshot() -> [String] {
        queries
    }
}
