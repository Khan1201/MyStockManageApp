import Foundation

final class TradeHistoryRepositoryImpl: TradeHistoryRepository {
    private let localDataSource: any TradeHistoryLocalDataSource

    init(localDataSource: any TradeHistoryLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchTrades() async throws -> [TradeRecord] {
        let localTrades = try await localDataSource.fetchTrades()
        return try localTrades.map { try $0.toDomain() }
    }

    func saveTrade(_ trade: TradeRecord) async throws {
        try await localDataSource.saveTrade(TradeRecordDTO(tradeRecord: trade))
    }
}
