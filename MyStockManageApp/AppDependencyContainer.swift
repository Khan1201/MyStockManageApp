import Foundation

final class AppDependencyContainer {
    private let tradeHistoryPersistentStorage: TradeHistoryPersistentStorage
    private let fetchTradeHistoryUseCase: FetchTradeHistoryUseCase
    private let saveTradeUseCase: SaveTradeUseCase

    init(
        tradeHistoryPersistentStorage: TradeHistoryPersistentStorage = TradeHistoryPersistentStorage(),
        tradeHistoryRemoteDataSource: any TradeHistoryRemoteDataSource = TradeHistorySeedRemoteDataSource()
    ) {
        self.tradeHistoryPersistentStorage = tradeHistoryPersistentStorage

        let tradeHistoryLocalDataSource = CoreDataTradeHistoryLocalDataSource(
            persistentStorage: tradeHistoryPersistentStorage
        )
        let tradeHistoryRepository = TradeHistoryRepositoryImpl(
            localDataSource: tradeHistoryLocalDataSource,
            remoteDataSource: tradeHistoryRemoteDataSource
        )

        fetchTradeHistoryUseCase = FetchTradeHistoryUseCase(repository: tradeHistoryRepository)
        saveTradeUseCase = SaveTradeUseCase(repository: tradeHistoryRepository)
    }

    @MainActor
    func makeTradeHistoryViewModel() -> TradeHistoryViewModel {
        TradeHistoryViewModel(
            fetchTradeHistoryUseCase: fetchTradeHistoryUseCase,
            saveTradeUseCase: saveTradeUseCase
        )
    }
}

extension AppDependencyContainer {
    static func preview() -> AppDependencyContainer {
        AppDependencyContainer(
            tradeHistoryPersistentStorage: TradeHistoryPersistentStorage(inMemory: true)
        )
    }
}
