import XCTest
@testable import MyStockManageApp

final class TradeHistoryRepositoryImplTests: XCTestCase {
    func testFetchTradesLoadsRemoteDataWhenLocalStorageIsEmptyAndCachesIt() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let remoteTrades = [
            TradeRecordDTO(
                tradeRecord: TradeRecord(
                    symbol: "TSLA",
                    tradedAt: makeDate(year: 2026, month: 3, day: 15),
                    shareCount: 200,
                    transactionType: .buy,
                    strategy: .themeBased,
                    targetPrice: 250,
                    stopLoss: 150,
                    reasoning: "Seeded remotely"
                )
            )
        ]
        let repository = TradeHistoryRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: TradeHistoryRemoteDataSourceStub(trades: remoteTrades)
        )

        let fetchedTrades = try await repository.fetchTrades()
        let cachedTrades = try await localDataSource.fetchTrades()

        XCTAssertEqual(fetchedTrades.count, 1)
        XCTAssertEqual(fetchedTrades.first?.symbol, "TSLA")
        XCTAssertEqual(cachedTrades, remoteTrades)
    }

    func testSaveTradePersistsTradeIntoLocalStorage() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let repository = TradeHistoryRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: TradeHistoryRemoteDataSourceStub(trades: [])
        )
        let trade = TradeRecord(
            symbol: "AMD",
            tradedAt: makeDate(year: 2026, month: 4, day: 1),
            shareCount: 75,
            transactionType: .sell,
            strategy: .themeBased,
            targetPrice: 250,
            stopLoss: 150,
            reasoning: "Saved locally"
        )

        try await repository.saveTrade(trade)

        let storedTrades = try await localDataSource.fetchTrades()

        XCTAssertEqual(storedTrades.count, 1)
        XCTAssertEqual(try storedTrades.first?.toDomain(), trade)
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
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

private struct TradeHistoryRemoteDataSourceStub: TradeHistoryRemoteDataSource {
    let trades: [TradeRecordDTO]

    func fetchTrades() async throws -> [TradeRecordDTO] {
        trades
    }
}
