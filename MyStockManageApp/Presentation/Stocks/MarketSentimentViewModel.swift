import SwiftUI

final class MarketSentimentViewModel: ObservableObject {
    @Published private(set) var selectedFilter: MarketSentimentFilter

    let sections: [MarketSentimentSection]

    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.selectedFilter = .all
        self.sections = Self.content(for: stock)
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

    func didTapBackButton() {
        dismissAction()
    }

    func didSelectFilter(_ filter: MarketSentimentFilter) {
        selectedFilter = filter
    }
}

private extension MarketSentimentViewModel {
    static func content(for stock: PortfolioStock) -> [MarketSentimentSection] {
        let leadingHeadline: String
        switch stock.symbol {
        case "NVDA":
            leadingHeadline = "Nvidia shares surge as AI demand reaches new heights across global markets"
        case "TSLA":
            leadingHeadline = "Tesla shares rebound as autonomy roadmap restores confidence among growth investors"
        case "AAPL":
            leadingHeadline = "Apple demand outlook improves as services momentum offsets hardware uncertainty"
        default:
            leadingHeadline = "\(stock.companyName) sentiment improves as investors respond to fresh market catalysts"
        }

        return [
            MarketSentimentSection(
                id: "today",
                title: "TODAY",
                items: [
                    .init(
                        id: "today_1",
                        headline: leadingHeadline,
                        sourceName: "Bloomberg",
                        publishedAtText: "10:30 AM",
                        signal: .bullish
                    ),
                    .init(
                        id: "today_2",
                        headline: "Federal Reserve hints at potential interest rate hike in Q4 following inflation data",
                        sourceName: "Reuters",
                        publishedAtText: "09:15 AM",
                        signal: .bearish
                    )
                ]
            ),
            MarketSentimentSection(
                id: "yesterday",
                title: "YESTERDAY",
                items: [
                    .init(
                        id: "yesterday_1",
                        headline: "Tesla Gigafactory expansion approved, boosting long-term production outlook",
                        sourceName: "CNBC",
                        publishedAtText: "4:20 PM",
                        signal: .bullish
                    )
                ]
            ),
            MarketSentimentSection(
                id: "archive",
                title: "26 MAR 2015",
                items: [
                    .init(
                        id: "archive_1",
                        headline: "Oil prices dip as global supply outweighs projected seasonal demand",
                        sourceName: "WSJ",
                        publishedAtText: "11:05 AM",
                        signal: .bearish
                    ),
                    .init(
                        id: "archive_2",
                        headline: "Tech sector sees massive inflows as venture capital confidence returns",
                        sourceName: "Financial Times",
                        publishedAtText: "08:30 AM",
                        signal: .bullish
                    )
                ]
            )
        ]
    }
}
