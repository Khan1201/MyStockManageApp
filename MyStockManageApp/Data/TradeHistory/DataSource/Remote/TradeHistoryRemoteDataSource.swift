import Foundation

protocol TradeHistoryRemoteDataSource {
    func fetchTrades() async throws -> [TradeRecordDTO]
}
