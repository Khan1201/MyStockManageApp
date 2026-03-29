import SwiftUI

struct TradeEditorView: View {
    private static let screenTitle: LocalizedStringResource = "Edit Trade"
    private static let topSaveTitle: LocalizedStringResource = "Save"
    private static let stockTitle: LocalizedStringResource = "Stock"
    private static let stockPrompt: LocalizedStringResource = "Enter symbol or company"
    private static let transactionInfoTitle: LocalizedStringResource = "TRANSACTION INFO"
    private static let transactionTypeTitle: LocalizedStringResource = "Type"
    private static let dateTitle: LocalizedStringResource = "Date"
    private static let quantityTitle: LocalizedStringResource = "Quantity"
    private static let quantityPrompt: LocalizedStringResource = "0"
    private static let quantityUnitTitle: LocalizedStringResource = "SHARES"
    private static let strategyTitle: LocalizedStringResource = "STRATEGY"
    private static let strategyFieldTitle: LocalizedStringResource = "Strategy"
    private static let targetPriceTitle: LocalizedStringResource = "Target Price"
    private static let stopLossTitle: LocalizedStringResource = "Stop Loss"
    private static let pricePrompt: LocalizedStringResource = "0.00"
    private static let reasoningTitle: LocalizedStringResource = "REASONING"
    private static let reasoningPlaceholder: LocalizedStringResource = "Capture the thesis, catalyst, or risk setup behind this trade."
    private static let saveChangesTitle: LocalizedStringResource = "Save Changes"
    private static let discardChangesTitle: LocalizedStringResource = "Discard Changes"

    @ObservedObject var viewModel: TradeEditorViewModel
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            TradeEditorNavigationBarView(
                title: Self.screenTitle,
                saveTitle: Self.topSaveTitle,
                isSaveEnabled: viewModel.canSave,
                backAction: handleBackAction,
                saveAction: handleSaveAction
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    stockInputSection
                    transactionInfoSection
                    strategySection
                    reasoningSection
                    footerActions
                }
                .padding(.horizontal, 10)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .background(Self.screenBackground.ignoresSafeArea())
    }

    private var stockInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Self.stockTitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(Color(red: 0.61, green: 0.68, blue: 0.79))

            TextField("", text: stockBinding, prompt: Text(Self.stockPrompt))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .stock)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
                .padding(.bottom, 6)
        }
        .padding(.horizontal, 8)
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
                    transactionTypePicker
                }

                divider

                TradeEditorFieldRowView(
                    iconName: "calendar",
                    iconForeground: Color(red: 0.95, green: 0.40, blue: 0.14),
                    iconBackground: Color(red: 1.00, green: 0.94, blue: 0.90),
                    title: Self.dateTitle
                ) {
                    DatePicker(
                        "",
                        selection: tradeDateBinding,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(Color(red: 0.36, green: 0.42, blue: 0.55))
                }

                divider

                TradeEditorFieldRowView(
                    iconName: "shippingbox",
                    iconForeground: Color(red: 0.98, green: 0.42, blue: 0.08),
                    iconBackground: Color(red: 1.00, green: 0.95, blue: 0.91),
                    title: Self.quantityTitle
                ) {
                    quantityField
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
                    strategyMenu
                }

                if viewModel.shouldShowThemeBasedFields {
                    divider

                    TradeEditorFieldRowView(
                        iconName: "scope",
                        iconForeground: Color(red: 0.12, green: 0.72, blue: 0.41),
                        iconBackground: Color(red: 0.87, green: 0.98, blue: 0.91),
                        title: Self.targetPriceTitle
                    ) {
                        targetPriceField
                    }

                    divider

                    TradeEditorFieldRowView(
                        iconName: "chart.line.downtrend.xyaxis",
                        iconForeground: Color(red: 0.98, green: 0.27, blue: 0.38),
                        iconBackground: Color(red: 1.00, green: 0.92, blue: 0.94),
                        title: Self.stopLossTitle
                    ) {
                        stopLossField
                    }
                }
            }
        }
    }

    private var reasoningSection: some View {
        TradeEditorSectionCardView(title: Self.reasoningTitle) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color(red: 1.00, green: 0.95, blue: 0.91))
                        .frame(width: 30, height: 30)

                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 0.98, green: 0.42, blue: 0.08))
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.shouldShowReasoningPlaceholder {
                        Text(Self.reasoningPlaceholder)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.61, green: 0.68, blue: 0.79))
                            .padding(.top, 8)
                            .padding(.horizontal, 5)
                    }

                    TextEditor(text: reasoningBinding)
                        .focused($focusedField, equals: .reasoning)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 132)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.25, green: 0.30, blue: 0.40))
                        .background(Color.clear)
                }
            }
        }
    }

    private var footerActions: some View {
        VStack(spacing: 16) {
            Button(action: handleSaveAction) {
                Text(Self.saveChangesTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(viewModel.canSave ? Self.primaryButtonColor : Self.primaryButtonColor.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Self.primaryButtonColor.opacity(0.24), radius: 14, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSave)

            Button(action: handleDiscardAction) {
                Text(Self.discardChangesTitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.45, green: 0.49, blue: 0.60))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }

    private var transactionTypePicker: some View {
        HStack(spacing: 0) {
            ForEach(TradeHistoryTransactionType.allCases) { transactionType in
                Button {
                    viewModel.didSelectTransactionType(transactionType)
                } label: {
                    Text(transactionType.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            viewModel.transactionType == transactionType
                            ? transactionType.tintColor
                            : Color(red: 0.51, green: 0.57, blue: 0.68)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.transactionType == transactionType
                            ? transactionType.tintColor.opacity(0.14)
                            : .clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .frame(width: 114)
        .background(Color(red: 0.94, green: 0.96, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private var quantityField: some View {
        HStack(spacing: 8) {
            TextField("", text: quantityBinding, prompt: Text(Self.quantityPrompt))
                .focused($focusedField, equals: .quantity)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))
                .frame(minWidth: 56)

            Text(Self.quantityUnitTitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.61, green: 0.68, blue: 0.79))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 0.94, green: 0.96, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var targetPriceField: some View {
        priceField(
            text: targetPriceBinding,
            accentColor: Color(red: 0.12, green: 0.72, blue: 0.41)
        )
    }

    private var stopLossField: some View {
        priceField(
            text: stopLossBinding,
            accentColor: Color(red: 0.98, green: 0.27, blue: 0.38)
        )
    }

    private var strategyMenu: some View {
        Menu {
            ForEach(TradeEditorStrategy.allCases) { strategy in
                Button {
                    viewModel.didSelectStrategy(strategy)
                } label: {
                    if viewModel.strategy == strategy {
                        Label {
                            Text(strategy.title)
                        } icon: {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        Text(strategy.title)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(viewModel.strategy.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.45, green: 0.49, blue: 0.60))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func priceField(text: Binding<String>, accentColor: Color) -> some View {
        HStack(spacing: 8) {
            Text(verbatim: "$")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor)
                .frame(width: 18)

            TextField("", text: text, prompt: Text(Self.pricePrompt))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor)
                .frame(minWidth: 72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 0.94, green: 0.96, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
            .frame(height: 1)
    }

    private var stockBinding: Binding<String> {
        Binding(
            get: { viewModel.symbol },
            set: viewModel.didUpdateSymbol
        )
    }

    private var tradeDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.tradeDate },
            set: viewModel.didChangeTradeDate
        )
    }

    private var quantityBinding: Binding<String> {
        Binding(
            get: { viewModel.quantityText },
            set: viewModel.didChangeQuantityText
        )
    }

    private var reasoningBinding: Binding<String> {
        Binding(
            get: { viewModel.reasoning },
            set: viewModel.didChangeReasoning
        )
    }

    private var targetPriceBinding: Binding<String> {
        Binding(
            get: { viewModel.targetPriceText },
            set: viewModel.didChangeTargetPriceText
        )
    }

    private var stopLossBinding: Binding<String> {
        Binding(
            get: { viewModel.stopLossText },
            set: viewModel.didChangeStopLossText
        )
    }

    private func handleBackAction() {
        focusedField = nil
        viewModel.didTapBackButton()
    }

    private func handleSaveAction() {
        focusedField = nil
        Task {
            await viewModel.didTapSaveButton()
        }
    }

    private func handleDiscardAction() {
        focusedField = nil
        viewModel.didTapDiscardButton()
    }
}

private extension TradeEditorView {
    enum Field: Hashable {
        case stock
        case quantity
        case reasoning
    }

    static let screenBackground = Color(red: 0.97, green: 0.96, blue: 0.95)
    static let primaryButtonColor = Color(red: 0.98, green: 0.41, blue: 0.07)
}

struct TradeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TradeEditorView(
            viewModel: TradeEditorViewModel(
                symbol: "TSLA",
                saveTradeUseCase: .noop,
                onDismiss: {},
                onSave: { _ in }
            )
        )
    }
}
