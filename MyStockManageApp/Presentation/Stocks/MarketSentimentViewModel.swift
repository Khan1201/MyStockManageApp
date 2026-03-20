import SwiftUI

@MainActor
final class MarketSentimentViewModel: ObservableObject {
    @Published private(set) var selectedFilter: MarketSentimentFilter
    @Published private(set) var sections: [MarketSentimentSection]

    let stock: PortfolioStock

    private let fetchMarketSentimentUseCase: FetchMarketSentimentUseCase
    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        fetchMarketSentimentUseCase: FetchMarketSentimentUseCase = .noop,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.stock = stock
        self.selectedFilter = .all
        self.sections = []
        self.fetchMarketSentimentUseCase = fetchMarketSentimentUseCase
        self.dismissAction = dismissAction
    }

    var filteredSections: [MarketSentimentSection] {
        sections.compactMap { section in
            let filteredItems = section.items.filter { selectedFilter.includes($0.signal) }

            guard !filteredItems.isEmpty else {
                return nil
            }

            return MarketSentimentSection(
                id: section.id,
                title: section.title,
                items: filteredItems
            )
        }
    }

    func loadMarketSentiment() async {
        do {
            let loadedSections = try await fetchMarketSentimentUseCase.execute(stock: stock)
            sections = loadedSections.map {
                MarketSentimentSection(
                    id: $0.id,
                    title: $0.title,
                    items: $0.items.map {
                        MarketSentimentItem(
                            id: $0.id,
                            headline: $0.headline,
                            sourceName: $0.sourceName,
                            publishedAtText: $0.publishedAtText,
                            signal: $0.signal
                        )
                    }
                )
            }
        } catch {
            sections = []
        }
    }

    func didTapBackButton() {
        dismissAction()
    }

    func didSelectFilter(_ filter: MarketSentimentFilter) {
        selectedFilter = filter
    }
}
