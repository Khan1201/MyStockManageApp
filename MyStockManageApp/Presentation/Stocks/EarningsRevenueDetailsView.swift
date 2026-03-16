import SwiftUI

struct EarningsRevenueDetailsView: View {
    private static let screenTitle: LocalizedStringResource = "Earnings & Revenue Details"
    private static let currentFiscalYearTitle: LocalizedStringResource = "Current Fiscal Year"

    @StateObject private var viewModel: EarningsRevenueDetailsViewModel

    init(viewModel: EarningsRevenueDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            CenteredBackNavigationBarView(
                title: Self.screenTitle,
                backAction: viewModel.didTapBackButton
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    EarningsRevenueYearFilterBarView(
                        years: viewModel.yearCategories,
                        selectedYear: viewModel.selectedYear,
                        action: viewModel.didSelectYear
                    )

                    HStack(alignment: .center, spacing: 8) {
                        Text(verbatim: viewModel.selectedYearText)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(Self.primaryTextColor)

                        if viewModel.isCurrentFiscalYearSelected {
                            Text(Self.currentFiscalYearTitle)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Self.currentFiscalYearTextColor)
                                .padding(.horizontal, 10)
                                .frame(height: 24)
                                .background(
                                    Capsule()
                                        .fill(Self.currentFiscalYearBackgroundColor)
                                )
                        }

                        Spacer(minLength: 0)
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.quarterItems) { item in
                            EarningsRevenueQuarterCardView(item: item)
                        }
                    }

                    EarningsRevenueLegendView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 2)
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Self.backgroundColor.ignoresSafeArea())
    }

    private static let backgroundColor = Color(red: 0.97, green: 0.96, blue: 0.95)
    private static let primaryTextColor = Color(red: 0.10, green: 0.14, blue: 0.23)
    private static let currentFiscalYearBackgroundColor = Color(red: 1.0, green: 0.92, blue: 0.88)
    private static let currentFiscalYearTextColor = Color(red: 0.97, green: 0.43, blue: 0.13)
}

struct EarningsRevenueDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsRevenueDetailsView(
            viewModel: EarningsRevenueDetailsViewModel(
                stock: PortfolioStock(
                    symbol: "AAPL",
                    companyName: "Apple Inc.",
                    price: 189.43,
                    changePercent: 1.24,
                    logoStyle: .apple
                ),
                currentYear: 2026
            )
        )
    }
}
