import Foundation

struct TradeHistoryTransaction: Identifiable, Equatable {
    let id: String
    let symbol: String
    let tradedAt: Date
    let shareCount: Int
    let transactionType: TradeHistoryTransactionType

    init(
        symbol: String,
        tradedAt: Date,
        shareCount: Int,
        transactionType: TradeHistoryTransactionType
    ) {
        self.id = "\(symbol)-\(Int(tradedAt.timeIntervalSince1970))-\(transactionType.rawValue)"
        self.symbol = symbol
        self.tradedAt = tradedAt
        self.shareCount = shareCount
        self.transactionType = transactionType
    }

    var subtitleText: String {
        "\(Self.tradeDateFormatter.string(from: tradedAt)) · \(shareCount) Shares"
    }

    private static let tradeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yy/MM/dd"
        return formatter
    }()
}
