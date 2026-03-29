import SwiftUI

struct TradeDetailsView: View {
    private static let screenTitle: LocalizedStringResource = "Trade Details"
    private static let editTitle: LocalizedStringResource = "Edit"
    private static let transactionInfoTitle: LocalizedStringResource = "TRANSACTION INFO"
    private static let transactionTypeTitle: LocalizedStringResource = "Type"
    private static let dateTitle: LocalizedStringResource = "Date"
    private static let quantityTitle: LocalizedStringResource = "Quantity"
    private static let strategyTitle: LocalizedStringResource = "STRATEGY"
    private static let strategyFieldTitle: LocalizedStringResource = "Strategy"
    private static let targetPriceTitle: LocalizedStringResource = "Target Price"
    private static let stopLossTitle: LocalizedStringResource = "Stop Loss"
    private static let reasoningTitle: LocalizedStringResource = "REASONING"
    private static let performanceAnalyticsTitle: LocalizedStringResource = "View Performance Analytics"

    @ObservedObject var viewModel: TradeDetailsViewModel

    var body: some View {
        Group {
            if let tradeEditorViewModel = viewModel.tradeEditorViewModel {
                TradeEditorView(viewModel: tradeEditorViewModel)
            } else {
                detailsContent
            }
        }
    }

    private var detailsContent: some View {
        VStack(spacing: 0) {
            TradeDetailsNavigationBarView(
                title: Self.screenTitle,
                editTitle: Self.editTitle,
                backAction: viewModel.didTapBackButton,
                editAction: viewModel.didTapEditButton
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    symbolHeader
                    transactionInfoSection
                    strategySection
                    reasoningSection
                }
                .padding(.horizontal, 8)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .background(Self.screenBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            footerButton
        }
    }

    private var symbolHeader: some View {
        Text(verbatim: viewModel.symbolText)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
            .padding(.horizontal, 8)
            .padding(.top, 2)
    }

    private var transactionInfoSection: some View {
        TradeEditorSectionCardView(title: Self.transactionInfoTitle) {
            VStack(spacing: 16) {
                TradeEditorFieldRowView(
                    iconName: "plus.circle",
                    iconForeground: Color(red: 0.10, green: 0.70, blue: 0.37),
                    iconBackground: Color(red: 0.87, green: 0.98, blue: 0.91),
                    title: Self.transactionTypeTitle
                ) {
                    TradeDetailsStatusBadgeView(
                        title: viewModel.transaction.transactionType.title,
                        foregroundColor: viewModel.transaction.transactionType.tintColor,
                        backgroundColor: viewModel.transaction.transactionType.tintColor.opacity(0.14)
                    )
                }

                divider

                TradeEditorFieldRowView(
                    iconName: "calendar",
                    iconForeground: Color(red: 0.95, green: 0.40, blue: 0.14),
                    iconBackground: Color(red: 1.00, green: 0.94, blue: 0.90),
                    title: Self.dateTitle
                ) {
                    valueText(viewModel.tradeDateText)
                }

                divider

                TradeEditorFieldRowView(
                    iconName: "shippingbox",
                    iconForeground: Color(red: 0.98, green: 0.42, blue: 0.08),
                    iconBackground: Color(red: 1.00, green: 0.95, blue: 0.91),
                    title: Self.quantityTitle
                ) {
                    valueText(viewModel.shareCountText)
                }
            }
        }
    }

    private var strategySection: some View {
        TradeEditorSectionCardView(title: Self.strategyTitle) {
            VStack(spacing: 16) {
                TradeEditorFieldRowView(
                    iconName: "flag.2.crossed",
                    iconForeground: Color(red: 0.98, green: 0.42, blue: 0.08),
                    iconBackground: Color(red: 1.00, green: 0.95, blue: 0.91),
                    title: Self.strategyFieldTitle
                ) {
                    valueText(viewModel.transaction.strategy.title)
                }

                if viewModel.shouldShowThemeBasedFields {
                    divider

                    TradeEditorFieldRowView(
                        iconName: "scope",
                        iconForeground: Color(red: 0.12, green: 0.72, blue: 0.41),
                        iconBackground: Color(red: 0.87, green: 0.98, blue: 0.91),
                        title: Self.targetPriceTitle
                    ) {
                        valueText(
                            viewModel.targetPriceText,
                            color: Color(red: 0.12, green: 0.72, blue: 0.41)
                        )
                    }

                    divider

                    TradeEditorFieldRowView(
                        iconName: "chart.line.downtrend.xyaxis",
                        iconForeground: Color(red: 0.98, green: 0.27, blue: 0.38),
                        iconBackground: Color(red: 1.00, green: 0.92, blue: 0.94),
                        title: Self.stopLossTitle
                    ) {
                        valueText(
                            viewModel.stopLossText,
                            color: Color(red: 0.98, green: 0.27, blue: 0.38)
                        )
                    }
                }
            }
        }
    }

    private var reasoningSection: some View {
        TradeEditorSectionCardView(title: Self.reasoningTitle) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 0.99, green: 0.82, blue: 0.72))
                    .frame(width: 22)
                    .padding(.top, 2)

                Text(verbatim: viewModel.reasoningText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .lineSpacing(4)
                    .foregroundStyle(Color(red: 0.25, green: 0.30, blue: 0.40))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 6)
        }
    }

    private var footerButton: some View {
        Button(action: viewModel.didTapPerformanceAnalyticsButton) {
            Text(Self.performanceAnalyticsTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Self.primaryButtonColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Self.primaryButtonColor.opacity(0.24), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Self.screenBackground)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
            .frame(height: 1)
    }

    private func valueText(
        _ text: String,
        color: Color = Color(red: 0.12, green: 0.16, blue: 0.28)
    ) -> some View {
        Text(verbatim: text)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .multilineTextAlignment(.trailing)
    }

    private func valueText(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
            .multilineTextAlignment(.trailing)
    }
}

private extension TradeDetailsView {
    static let screenBackground = Color(red: 0.97, green: 0.96, blue: 0.95)
    static let primaryButtonColor = Color(red: 0.98, green: 0.41, blue: 0.07)
}

struct TradeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TradeDetailsView(
            viewModel: TradeDetailsViewModel(
                transaction: TradeHistoryTransaction(
                    symbol: "TSLA",
                    tradedAt: .now,
                    shareCount: 200,
                    transactionType: .buy,
                    strategy: .themeBased,
                    targetPrice: 250,
                    stopLoss: 150,
                    reasoning: "Entering based on recent breakthrough in battery technology and strong quarterly delivery numbers."
                ),
                onDismiss: {}
            )
        )
    }
}
