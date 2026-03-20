import Foundation

final class TradeHistoryRepositoryImpl: TradeHistoryRepository {
    private let localDataSource: any TradeHistoryLocalDataSource
    private let remoteDataSource: any TradeHistoryRemoteDataSource

    init(
        localDataSource: any TradeHistoryLocalDataSource,
        remoteDataSource: any TradeHistoryRemoteDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func fetchTrades() async throws -> [TradeRecord] {
        let localTrades = try await localDataSource.fetchTrades()
        if !localTrades.isEmpty {
            return try localTrades.map { try $0.toDomain() }
        }

        let remoteTrades = try await remoteDataSource.fetchTrades()
        if !remoteTrades.isEmpty {
            try await localDataSource.saveTrades(remoteTrades)
        }

        return try remoteTrades.map { try $0.toDomain() }
    }

    func saveTrade(_ trade: TradeRecord) async throws {
        try await localDataSource.saveTrade(TradeRecordDTO(tradeRecord: trade))
    }
}
