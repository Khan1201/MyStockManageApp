import Foundation

struct FetchStocksOverviewUseCase {
    private let operation: () async throws -> StocksOverview

    init(repository: any StocksRepository) {
        operation = {
            try await repository.fetchStocksOverview()
        }
    }

    init(operation: @escaping () async throws -> StocksOverview) {
        self.operation = operation
    }

    func execute() async throws -> StocksOverview {
        try await operation()
    }
}

extension FetchStocksOverviewUseCase {
    static let noop = FetchStocksOverviewUseCase(
        operation: {
            StocksOverview(portfolio: [], searchableStocks: [])
        }
    )
}
