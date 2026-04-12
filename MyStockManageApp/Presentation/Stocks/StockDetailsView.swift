import SwiftUI

struct StockDetailsView: View {
    private static let screenTitle: LocalizedStringResource = "Stock Details"
    private static let analystForecastsTitle: LocalizedStringResource = "Analyst Forecasts"
    private static let marketSentimentTitle: LocalizedStringResource = "Market Sentiment"
    private static let earningsTitle: LocalizedStringResource = "Earnings & Revenue Estimates"
    private static let seeAllTitle: LocalizedStringResource = "SEE ALL"
    private static let sentimentTimeframeTitle: LocalizedStringResource = "LAST 2 WEEKS"

    @StateObject private var viewModel: StockDetailsViewModel

    init(viewModel: StockDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            StockDetailsNavigationBarView(
                title: Self.screenTitle,
                closeAction: viewModel.didTapCloseButton,
                addAction: viewModel.didTapAddButton,
                addButtonSymbolName: viewModel.addButtonSymbolName,
                addButtonAccessibilityLabel: viewModel.addButtonAccessibilityLabel
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    StockDetailsHeaderView(
                        stock: viewModel.stock,
                        priceText: viewModel.priceText,
                        priceChangeText: viewModel.priceChangeText,
                        priceChangeColor: viewModel.priceChangeColor
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        StockSectionHeaderView(
                            title: Self.analystForecastsTitle,
                            actionTitle: Self.seeAllTitle,
                            action: viewModel.didTapAnalystForecastsSeeAll
                        )
                        StockForecastsCardView(items: viewModel.analystForecasts)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        StockSectionHeaderView(
                            title: Self.marketSentimentTitle,
                            actionTitle: Self.seeAllTitle,
                            action: viewModel.didTapMarketSentimentSeeAll
                        )
                        StockSentimentCardView(
                            timeframeTitle: Self.sentimentTimeframeTitle,
                            items: viewModel.sentimentItems
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        StockSectionHeaderView(
                            title: Self.earningsTitle,
                            actionTitle: Self.seeAllTitle,
                            action: viewModel.didTapEarningsEstimatesSeeAll
                        )
                        StockEarningsEstimatesCardView(rows: viewModel.earningsEstimateRows)
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
        .fullScreenCover(isPresented: analystForecastsPresentedBinding) {
            AnalystForecastsView(viewModel: viewModel.analystForecastsViewModel)
        }
        .fullScreenCover(isPresented: marketSentimentPresentedBinding) {
            MarketSentimentView(viewModel: viewModel.marketSentimentViewModel)
        }
        .fullScreenCover(isPresented: earningsRevenueDetailsPresentedBinding) {
            EarningsRevenueDetailsView(viewModel: viewModel.earningsRevenueDetailsViewModel)
        }
        .task {
            await viewModel.loadStockInsights()
        }
    }

    private static let backgroundColor = Color(red: 0.96, green: 0.94, blue: 0.93)

    private var analystForecastsPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isPresentingAnalystForecasts },
            set: { isPresented in
                guard !isPresented else {
                    return
                }

                viewModel.didDismissAnalystForecasts()
            }
        )
    }

    private var marketSentimentPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isPresentingMarketSentiment },
            set: { isPresented in
                guard !isPresented else {
                    return
                }

                viewModel.didDismissMarketSentiment()
            }
        )
    }

    private var earningsRevenueDetailsPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isPresentingEarningsRevenueDetails },
            set: { isPresented in
                guard !isPresented else {
                    return
                }

                viewModel.didDismissEarningsRevenueDetails()
            }
        )
    }
}

struct StockDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailsView(
            viewModel: AppDependencyContainer.preview().makeStockDetailsViewModel(
                stock: PortfolioStock(
                    symbol: "AAPL",
                    companyName: "Apple Inc.",
                    price: 189.43,
                    changePercent: 1.24,
                    brand: .apple
                )
            )
        )
    }
}
