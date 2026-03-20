import Foundation

protocol TradeHistoryLocalDataSource {
    func fetchTrades() async throws -> [TradeRecordDTO]
    func saveTrade(_ trade: TradeRecordDTO) async throws
    func saveTrades(_ trades: [TradeRecordDTO]) async throws
}
