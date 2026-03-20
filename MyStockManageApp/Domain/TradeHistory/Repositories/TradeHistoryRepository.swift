import Foundation

protocol TradeHistoryRepository {
    func fetchTrades() async throws -> [TradeRecord]
    func saveTrade(_ trade: TradeRecord) async throws
}
