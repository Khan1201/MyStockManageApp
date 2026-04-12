import Foundation

final class AppDependencyContainer {
    private let tradeHistoryPersistentStorage: TradeHistoryPersistentStorage
    private let fetchTradeHistoryUseCase: FetchTradeHistoryUseCase
    private let saveTradeUseCase: SaveTradeUseCase
    private let fetchStocksOverviewUseCase: FetchStocksOverviewUseCase
    private let searchStocksUseCase: SearchStocksUseCase
    private let fetchStockUseCase: FetchStockUseCase
    private let fetchStockInsightsUseCase: FetchStockInsightsUseCase
    private let fetchAnalystForecastsUseCase: FetchAnalystForecastsUseCase
    private let fetchMarketSentimentUseCase: FetchMarketSentimentUseCase
    private let fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase

    init(
        tradeHistoryPersistentStorage: TradeHistoryPersistentStorage = TradeHistoryPersistentStorage(),
        stocksRemoteDataSource: any StocksRemoteDataSource = StocksFinnhubRemoteDataSource()
    ) {
        self.tradeHistoryPersistentStorage = tradeHistoryPersistentStorage

        let tradeHistoryLocalDataSource = CoreDataTradeHistoryLocalDataSource(
            persistentStorage: tradeHistoryPersistentStorage
        )
        let tradeHistoryRepository = TradeHistoryRepositoryImpl(
            localDataSource: tradeHistoryLocalDataSource
        )

        fetchTradeHistoryUseCase = FetchTradeHistoryUseCase(repository: tradeHistoryRepository)
        saveTradeUseCase = SaveTradeUseCase(repository: tradeHistoryRepository)

        let stocksRepository = StocksRepositoryImpl(
            remoteDataSource: stocksRemoteDataSource
        )

        fetchStocksOverviewUseCase = FetchStocksOverviewUseCase(repository: stocksRepository)
        searchStocksUseCase = SearchStocksUseCase(repository: stocksRepository)
        fetchStockUseCase = FetchStockUseCase(repository: stocksRepository)
        fetchStockInsightsUseCase = FetchStockInsightsUseCase(repository: stocksRepository)
        fetchAnalystForecastsUseCase = FetchAnalystForecastsUseCase(repository: stocksRepository)
        fetchMarketSentimentUseCase = FetchMarketSentimentUseCase(repository: stocksRepository)
        fetchEarningsRevenueUseCase = FetchEarningsRevenueUseCase(repository: stocksRepository)
    }

    @MainActor
    func makeStocksViewModel() -> StocksViewModel {
        StocksViewModel(
            fetchStocksOverviewUseCase: fetchStocksOverviewUseCase,
            searchStocksUseCase: searchStocksUseCase,
            fetchStockUseCase: fetchStockUseCase,
            stockDetailsViewModelBuilder: { [weak self] stock, dismissAction in
                guard let self else {
                    return StockDetailsViewModel(stock: stock, dismissAction: dismissAction)
                }

                return self.makeStockDetailsViewModel(
                    stock: stock,
                    dismissAction: dismissAction
                )
            }
        )
    }

    @MainActor
    func makeStockDetailsViewModel(
        stock: PortfolioStock,
        dismissAction: @escaping () -> Void = {}
    ) -> StockDetailsViewModel {
        StockDetailsViewModel(
            stock: stock,
            fetchStockInsightsUseCase: fetchStockInsightsUseCase,
            fetchAnalystForecastsUseCase: fetchAnalystForecastsUseCase,
            fetchMarketSentimentUseCase: fetchMarketSentimentUseCase,
            fetchEarningsRevenueUseCase: fetchEarningsRevenueUseCase,
            dismissAction: dismissAction
        )
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
