import SwiftUI

struct AnalystForecastsView: View {
    private static let screenTitle: LocalizedStringResource = "Analyst Forecasts"

    @StateObject private var viewModel: AnalystForecastsViewModel

    init(viewModel: AnalystForecastsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            CenteredBackNavigationBarView(
                title: Self.screenTitle,
                backAction: viewModel.didTapBackButton
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        ForEach(viewModel.overviewItems) { item in
                            AnalystForecastSummaryCardView(item: item)
                        }
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.forecasts.enumerated()), id: \.element.id) { index, item in
                            AnalystForecastRowView(item: item)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)

                            if index < viewModel.forecasts.count - 1 {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.03), radius: 12, y: 6)
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.top, 18)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Self.backgroundColor.ignoresSafeArea())
        .task {
            await viewModel.loadAnalystForecasts()
        }
    }

    private static let backgroundColor = Color(red: 0.96, green: 0.94, blue: 0.93)
}

struct AnalystForecastsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalystForecastsView(
            viewModel: AnalystForecastsViewModel(
                stock: PortfolioStock(
                    symbol: "AAPL",
                    companyName: "Apple Inc.",
                    price: 189.43,
                    changePercent: 1.24
                )
            )
        )
    }
}
