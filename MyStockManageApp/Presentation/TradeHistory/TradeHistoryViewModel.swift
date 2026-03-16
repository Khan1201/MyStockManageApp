import SwiftUI

final class TradeHistoryViewModel: ObservableObject {
    @Published private(set) var selectedFilter: TradeHistoryFilter

    private let transactions: [TradeHistoryTransaction]
    private let calendar: Calendar

    init(
        selectedFilter: TradeHistoryFilter = .all,
        transactions: [TradeHistoryTransaction] = TradeHistoryViewModel.defaultTransactions,
        calendar: Calendar = TradeHistoryViewModel.defaultCalendar
    ) {
        self.selectedFilter = selectedFilter
        self.transactions = transactions
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
        // Reserved for the future trade creation flow.
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
    static let defaultTransactions: [TradeHistoryTransaction] = [
        TradeHistoryTransaction(
            symbol: "TSLA",
            tradedAt: makeDate(year: 2026, month: 3, day: 15),
            shareCount: 200,
            transactionType: .buy
        ),
        TradeHistoryTransaction(
            symbol: "AAPL",
            tradedAt: makeDate(year: 2026, month: 3, day: 10),
            shareCount: 50,
            transactionType: .sell
        ),
        TradeHistoryTransaction(
            symbol: "NVDA",
            tradedAt: makeDate(year: 2026, month: 3, day: 5),
            shareCount: 100,
            transactionType: .buy
        ),
        TradeHistoryTransaction(
            symbol: "GOOGL",
            tradedAt: makeDate(year: 2026, month: 2, day: 28),
            shareCount: 30,
            transactionType: .sell
        ),
        TradeHistoryTransaction(
            symbol: "MSFT",
            tradedAt: makeDate(year: 2026, month: 2, day: 15),
            shareCount: 80,
            transactionType: .buy
        )
    ]

    static let defaultCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    private static let monthHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = defaultCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = defaultCalendar.timeZone
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let monthIdentifierFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = defaultCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = defaultCalendar.timeZone
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    private static func makeDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(
            calendar: defaultCalendar,
            timeZone: defaultCalendar.timeZone,
            year: year,
            month: month,
            day: day
        )

        return defaultCalendar.date(from: components) ?? .distantPast
    }
}
