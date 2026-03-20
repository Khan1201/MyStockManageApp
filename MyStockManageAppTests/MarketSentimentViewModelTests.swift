import XCTest
@testable import MyStockManageApp

@MainActor
final class MarketSentimentViewModelTests: XCTestCase {
    func testDefaultFilterShowsAllSectionsAndItems() async {
        let sut = makeSUT()

        await sut.loadMarketSentiment()

        XCTAssertEqual(sut.selectedFilter, .all)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "yesterday", "archive"])
        XCTAssertEqual(sut.filteredSections.flatMap(\.items).count, 5)
    }

    func testDidSelectBullishFilterShowsOnlyBullishItems() async {
        let sut = makeSUT()
        await sut.loadMarketSentiment()

        sut.didSelectFilter(.bullish)

        XCTAssertEqual(sut.selectedFilter, .bullish)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "yesterday", "archive"])
        XCTAssertEqual(
            sut.filteredSections.flatMap(\.items).map(\.signal),
            [.bullish, .bullish, .bullish]
        )
    }

    func testDidSelectBearishFilterDropsEmptySections() async {
        let sut = makeSUT()
        await sut.loadMarketSentiment()

        sut.didSelectFilter(.bearish)

        XCTAssertEqual(sut.selectedFilter, .bearish)
        XCTAssertEqual(sut.filteredSections.map(\.id), ["today", "archive"])
        XCTAssertEqual(
            sut.filteredSections.flatMap(\.items).map(\.signal),
            [.bearish, .bearish]
        )
    }

    func testDidTapBackButtonInvokesDismissAction() {
        var dismissCallCount = 0
        let sut = MarketSentimentViewModel(
            stock: makeNVDAStock(),
            dismissAction: {
                dismissCallCount += 1
            }
        )

        sut.didTapBackButton()

        XCTAssertEqual(dismissCallCount, 1)
    }

    private func makeSUT() -> MarketSentimentViewModel {
        MarketSentimentViewModel(
            stock: makeNVDAStock(),
            fetchMarketSentimentUseCase: FetchMarketSentimentUseCase(
                operation: { _ in
                    [
                        SentimentSection(
                            id: "today",
                            title: "TODAY",
                            items: [
                                SentimentArticle(id: "today_1", headline: "Bullish item", sourceName: "Bloomberg", publishedAtText: "10:30 AM", signal: .bullish),
                                SentimentArticle(id: "today_2", headline: "Bearish item", sourceName: "Reuters", publishedAtText: "09:15 AM", signal: .bearish)
                            ]
                        ),
                        SentimentSection(
                            id: "yesterday",
                            title: "YESTERDAY",
                            items: [
                                SentimentArticle(id: "yesterday_1", headline: "Bullish item", sourceName: "CNBC", publishedAtText: "4:20 PM", signal: .bullish)
                            ]
                        ),
                        SentimentSection(
                            id: "archive",
                            title: "26 MAR 2015",
                            items: [
                                SentimentArticle(id: "archive_1", headline: "Bearish item", sourceName: "WSJ", publishedAtText: "11:05 AM", signal: .bearish),
                                SentimentArticle(id: "archive_2", headline: "Bullish item", sourceName: "Financial Times", publishedAtText: "08:30 AM", signal: .bullish)
                            ]
                        )
                    ]
                }
            )
        )
    }

    private func makeNVDAStock() -> PortfolioStock {
        .init(
            symbol: "NVDA",
            companyName: "NVIDIA Corporation",
            price: 924.79,
            changePercent: 2.38,
            logoStyle: .nvidia
        )
    }
}
