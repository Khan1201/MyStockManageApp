import Foundation

struct SearchStocksUseCase {
    private let operation: (String) async throws -> [StockSearchResult]

    init(repository: any StocksRepository) {
        operation = { query in
            try await repository.searchStocks(query: query)
        }
    }

    init(operation: @escaping (String) async throws -> [StockSearchResult]) {
        self.operation = operation
    }

    func execute(query: String) async throws -> [StockSearchResult] {
        try await operation(query)
    }
}

extension SearchStocksUseCase {
    static let noop = SearchStocksUseCase(
        operation: { _ in [] }
    )
}
