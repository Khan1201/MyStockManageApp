import XCTest
@testable import MyStockManageApp

@MainActor
final class StocksViewModelTests: XCTestCase {
    func testDisplayedStocksReturnsAllStocksWhenSearchIsEmpty() {
        let sut = StocksViewModel(portfolio: makePortfolio())

        XCTAssertEqual(sut.displayedStocks.map(\.symbol), ["AAPL", "MSFT", "TSLA"])
    }

    func testDisplayedStocksFiltersCaseInsensitiveBySymbolOrCompanyName() {
        let sut = StocksViewModel(portfolio: makePortfolio())

        sut.searchText = "soft"
        XCTAssertEqual(sut.displayedStocks.map(\.symbol), ["MSFT"])

        sut.searchText = "tsla"
        XCTAssertEqual(sut.displayedStocks.map(\.symbol), ["TSLA"])
    }

    func testIsShowingSearchResultsIsTrueOnlyForNonWhitespaceQuery() {
        let sut = StocksViewModel(
            portfolio: makePortfolio(),
            searchableStocks: makeSearchResults()
        )

        XCTAssertFalse(sut.isShowingSearchResults)

        sut.searchText = "   "
        XCTAssertFalse(sut.isShowingSearchResults)

        sut.searchText = "a"
        XCTAssertTrue(sut.isShowingSearchResults)
    }

    func testSearchResultsFiltersMatchingSearchableStocks() {
        let sut = StocksViewModel(
            portfolio: makePortfolio(),
            searchableStocks: makeSearchResults()
        )

        sut.searchText = "a"

        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AAPL", "AMZN", "AMD", "ADBE"])
    }

    func testDidTapClearSearchResetsQueryAndHidesSearchResults() {
        let sut = StocksViewModel(
            portfolio: makePortfolio(),
            searchableStocks: makeSearchResults()
        )

        sut.searchText = "amd"

        XCTAssertTrue(sut.isShowingSearchResults)
        XCTAssertEqual(sut.searchResults.map(\.symbol), ["AMD"])

        sut.didTapClearSearch()

        XCTAssertEqual(sut.searchText, "")
        XCTAssertFalse(sut.isShowingSearchResults)
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func testDidTapEditButtonMarksEditingState() {
        let sut = StocksViewModel(portfolio: makePortfolio())

        XCTAssertFalse(sut.isEditingPortfolio)

        sut.didTapEditButton()

        XCTAssertTrue(sut.isEditingPortfolio)
    }

    func testDidSelectPortfolioStockStoresSelection() {
        let sut = StocksViewModel(portfolio: makePortfolio())
        let stock = makePortfolio()[1]

        sut.didSelectPortfolioStock(stock)

        XCTAssertEqual(sut.selectedPortfolioStock, stock)
    }

    func testDidDismissPortfolioStockDetailsClearsSelection() {
        let sut = StocksViewModel(portfolio: makePortfolio())

        sut.didSelectPortfolioStock(makePortfolio()[0])
        XCTAssertNotNil(sut.selectedPortfolioStock)

        sut.didDismissPortfolioStockDetails()

        XCTAssertNil(sut.selectedPortfolioStock)
    }

    func testDidSelectSearchResultStockStoresSelection() {
        let sut = StocksViewModel(
            portfolio: makePortfolio(),
            searchableStocks: makeSearchResults()
        )
        let stock = makeSearchResults()[2]

        sut.didSelectSearchResultStock(stock)

        XCTAssertEqual(sut.selectedSearchResultStock, stock)
    }

    func testPortfolioStockProvidesFormattedDisplayValues() {
        let stock = PortfolioStock(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: -1.24,
            logoStyle: .apple
        )

        XCTAssertEqual(stock.priceText, "$189.43")
        XCTAssertEqual(stock.changeText, "-1.24%")
        XCTAssertEqual(stock.changeDirection, .loss)
    }

    private func makePortfolio() -> [PortfolioStock] {
        [
            .init(symbol: "AAPL", companyName: "Apple Inc.", price: 189.43, changePercent: 1.24, logoStyle: .apple),
            .init(symbol: "MSFT", companyName: "Microsoft Corp", price: 415.32, changePercent: -0.45, logoStyle: .microsoft),
            .init(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15, logoStyle: .tesla)
        ]
    }

    private func makeSearchResults() -> [SearchResultStock] {
        [
            .init(symbol: "AAPL", companyName: "Apple Inc.", logoStyle: .apple),
            .init(symbol: "AMZN", companyName: "Amazon.com, Inc.", logoStyle: .amazon),
            .init(symbol: "AMD", companyName: "Advanced Micro Devices, Inc.", logoStyle: .amd),
            .init(symbol: "ADBE", companyName: "Adobe Inc.", logoStyle: .adobe)
        ]
    }
}
