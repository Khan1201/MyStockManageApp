import Foundation

struct FetchStockInsightsUseCase {
    private let operation: (Stock) async throws -> StockInsights

    init(repository: any StocksRepository) {
        operation = { stock in
            try await repository.fetchStockInsights(for: stock)
        }
    }

    init(operation: @escaping (Stock) async throws -> StockInsights) {
        self.operation = operation
    }

    func execute(stock: Stock) async throws -> StockInsights {
        try await operation(stock)
    }
}

extension FetchStockInsightsUseCase {
    static let noop = FetchStockInsightsUseCase(
        operation: { _ in
            StockInsights(forecastSummary: [], sentimentSummary: [], earningsEstimates: [])
        }
    )
}
