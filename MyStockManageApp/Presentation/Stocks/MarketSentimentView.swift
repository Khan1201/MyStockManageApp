import SwiftUI

struct MarketSentimentView: View {
    private static let screenTitle: LocalizedStringResource = "Market Sentiment"

    @StateObject private var viewModel: MarketSentimentViewModel

    init(viewModel: MarketSentimentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            AnalystForecastsNavigationBarView(
                title: Self.screenTitle,
                backAction: viewModel.didTapBackButton
            )

            MarketSentimentFilterBarView(
                selectedFilter: viewModel.selectedFilter,
                action: viewModel.didSelectFilter
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(viewModel.filteredSections) { section in
                        MarketSentimentSectionView(section: section)
                    }
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Self.backgroundColor.ignoresSafeArea())
    }

    private static let backgroundColor = Color.white
}

struct MarketSentimentView_Previews: PreviewProvider {
    static var previews: some View {
        MarketSentimentView(
            viewModel: MarketSentimentViewModel(
                stock: PortfolioStock(
                    symbol: "NVDA",
                    companyName: "NVIDIA Corporation",
                    price: 924.79,
                    changePercent: 2.38,
                    logoStyle: .nvidia
                )
            )
        )
    }
}
