import SwiftUI

@MainActor
final class TradeHistoryViewModel: ObservableObject {
    @Published private(set) var selectedFilter: TradeHistoryFilter
    @Published private(set) var tradeDetailsViewModel: TradeDetailsViewModel?
    @Published private(set) var tradeEditorViewModel: TradeEditorViewModel?
    @Published private(set) var transactions: [TradeHistoryTransaction]

    private let calendar: Calendar
    private let fetchTradeHistoryUseCase: FetchTradeHistoryUseCase
    private let saveTradeUseCase: SaveTradeUseCase

    init(
        selectedFilter: TradeHistoryFilter = .all,
        transactions: [TradeHistoryTransaction] = [],
        fetchTradeHistoryUseCase: FetchTradeHistoryUseCase = .noop,
        saveTradeUseCase: SaveTradeUseCase = .noop,
        calendar: Calendar = tradeHistoryDefaultCalendar
    ) {
        self.selectedFilter = selectedFilter
        self.transactions = transactions
        self.fetchTradeHistoryUseCase = fetchTradeHistoryUseCase
        self.saveTradeUseCase = saveTradeUseCase
        self.calendar = calendar
    }

    var displayedSections: [TradeHistoryMonthSection] {
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { transaction in
            monthStart(for: transaction.tradedAt) ?? transaction.tradedAt
        }

        return groupedTransactions.keys
            .sorted(by: >)
            .compactMap { month in
                guard let sectionTransactions = groupedTransactions[month]?.sorted(by: { $0.tradedAt > $1.tradedAt }) else {
                    return nil
                }

                return TradeHistoryMonthSection(
                    id: Self.monthIdentifierFormatter.string(from: month),
                    title: Self.monthHeaderFormatter.string(from: month).uppercased(),
                    transactions: sectionTransactions
                )
            }
    }

    var summaryText: String {
        let year = summaryYear(from: filteredTransactions)
        let buyCount = filteredTransactions.filter { $0.transactionType == .buy }.count
        let sellCount = filteredTransactions.filter { $0.transactionType == .sell }.count

        switch selectedFilter {
        case .all:
            return "\(year): \(buyCount) Buys, \(sellCount) Sells"
        case .buy:
            return "\(year): \(buyCount) Buys"
        case .sell:
            return "\(year): \(sellCount) Sells"
        }
    }

    func didSelectFilter(_ filter: TradeHistoryFilter) {
        selectedFilter = filter
    }

    func didTapAddTradeButton() {
        guard tradeDetailsViewModel == nil, tradeEditorViewModel == nil else {
            return
        }

        tradeEditorViewModel = TradeEditorViewModel(
            saveTradeUseCase: saveTradeUseCase,
            onDismiss: { [weak self] in
                self?.didDismissTradeEditor()
            },
            onSave: { [weak self] _ in
                await self?.loadTradeHistory()
            }
        )
    }

    func didSelectTransaction(_ transaction: TradeHistoryTransaction) {
        guard tradeDetailsViewModel == nil, tradeEditorViewModel == nil else {
            return
        }

        tradeDetailsViewModel = TradeDetailsViewModel(
            transaction: transaction,
            saveTradeUseCase: saveTradeUseCase,
            onDismiss: { [weak self] in
                self?.didDismissTradeDetails()
            },
            onTradeSaved: { [weak self] _ in
                await self?.loadTradeHistory()
            }
        )
    }

    func didDismissTradeDetails() {
        tradeDetailsViewModel = nil
    }

    func didDismissTradeEditor() {
        tradeEditorViewModel = nil
    }

    func loadTradeHistory() async {
        do {
            let tradeRecords = try await fetchTradeHistoryUseCase.execute()
            transactions = tradeRecords.map(TradeHistoryTransaction.init(tradeRecord:))
        } catch {
            transactions = []
        }
    }

    private var filteredTransactions: [TradeHistoryTransaction] {
        switch selectedFilter {
        case .all:
            return transactions
        case .buy:
            return transactions.filter { $0.transactionType == .buy }
        case .sell:
            return transactions.filter { $0.transactionType == .sell }
        }
    }

    private func monthStart(for date: Date) -> Date? {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))
    }

    private func summaryYear(from transactions: [TradeHistoryTransaction]) -> Int {
        guard let latestDate = transactions.map(\.tradedAt).max() else {
            return calendar.component(.year, from: Date())
        }

        return calendar.component(.year, from: latestDate)
    }
}

extension TradeHistoryViewModel {
    private static let monthHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = tradeHistoryDefaultCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tradeHistoryDefaultCalendar.timeZone
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let monthIdentifierFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = tradeHistoryDefaultCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tradeHistoryDefaultCalendar.timeZone
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()
}

private let tradeHistoryDefaultCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
    return calendar
}()
