import Foundation

struct TradeHistorySeedRemoteDataSource: TradeHistoryRemoteDataSource {
    func fetchTrades() async throws -> [TradeRecordDTO] {
        [
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "TSLA",
                    tradedAt: Self.makeDate(year: 2026, month: 3, day: 15),
                    shareCount: 200,
                    transactionType: .buy,
                    strategy: .themeBased,
                    targetPrice: 250,
                    stopLoss: 150,
                    reasoning: "Battery technology breakout and strong delivery momentum."
                )
            ),
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "AAPL",
                    tradedAt: Self.makeDate(year: 2026, month: 3, day: 10),
                    shareCount: 50,
                    transactionType: .sell,
                    strategy: .longTerm,
                    reasoning: "Trimmed position after valuation expansion."
                )
            ),
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "NVDA",
                    tradedAt: Self.makeDate(year: 2026, month: 3, day: 5),
                    shareCount: 100,
                    transactionType: .buy,
                    strategy: .themeBased,
                    targetPrice: 980,
                    stopLoss: 820,
                    reasoning: "AI infrastructure theme remains intact."
                )
            ),
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "GOOGL",
                    tradedAt: Self.makeDate(year: 2026, month: 2, day: 28),
                    shareCount: 30,
                    transactionType: .sell,
                    strategy: .longTerm,
                    reasoning: "Reduced exposure ahead of earnings."
                )
            ),
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "MSFT",
                    tradedAt: Self.makeDate(year: 2026, month: 2, day: 15),
                    shareCount: 80,
                    transactionType: .buy,
                    strategy: .longTerm,
                    reasoning: "Compounding cloud cash flows support long-term thesis."
                )
            )
        ]
    }
}

private extension TradeHistorySeedRemoteDataSource {
    static func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        )

        return calendar.date(from: components) ?? .distantPast
    }
}
