import XCTest
@testable import MyStockManageApp

final class TradeHistoryRepositoryImplTests: XCTestCase {
    func testFetchTradesReturnsLocalData() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let localTrade = TradeRecord(
            symbol: "TSLA",
            tradedAt: makeDate(year: 2026, month: 3, day: 15),
            shareCount: 200,
            transactionType: .buy,
            strategy: .themeBased,
            targetPrice: 250,
            stopLoss: 150,
            reasoning: "Saved locally"
        )
        try await localDataSource.saveTrade(TradeRecordDTO(tradeRecord: localTrade))
        let repository = TradeHistoryRepositoryImpl(localDataSource: localDataSource)

        let fetchedTrades = try await repository.fetchTrades()

        XCTAssertEqual(fetchedTrades, [localTrade])
    }

    func testFetchTradesReturnsEmptyArrayWhenLocalStorageIsEmpty() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let repository = TradeHistoryRepositoryImpl(localDataSource: localDataSource)

        let fetchedTrades = try await repository.fetchTrades()

        XCTAssertEqual(fetchedTrades, [])
    }

    func testSaveTradePersistsTradeIntoLocalStorage() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let repository = TradeHistoryRepositoryImpl(localDataSource: localDataSource)
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

    func testSaveTradeUpdatesExistingTradeInLocalStorage() async throws {
        let persistentStorage = TradeHistoryPersistentStorage(inMemory: true)
        let localDataSource = CoreDataTradeHistoryLocalDataSource(persistentStorage: persistentStorage)
        let repository = TradeHistoryRepositoryImpl(localDataSource: localDataSource)
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
        let updatedTrade = TradeRecord(
            id: trade.id,
            symbol: "AMD",
            tradedAt: makeDate(year: 2026, month: 4, day: 2),
            shareCount: 100,
            transactionType: .sell,
            strategy: .themeBased,
            targetPrice: 260,
            stopLoss: 140,
            reasoning: "Updated locally"
        )

        try await repository.saveTrade(trade)
        try await repository.saveTrade(updatedTrade)

        let storedTrades = try await localDataSource.fetchTrades()

        XCTAssertEqual(storedTrades.count, 1)
        XCTAssertEqual(try storedTrades.first?.toDomain(), updatedTrade)
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
