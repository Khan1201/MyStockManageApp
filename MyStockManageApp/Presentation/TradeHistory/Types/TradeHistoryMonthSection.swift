import Foundation

struct TradeHistoryMonthSection: Identifiable, Equatable {
    let id: String
    let title: String
    let transactions: [TradeHistoryTransaction]
}
