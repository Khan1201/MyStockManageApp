import Foundation

enum FetchStockUseCaseError: Error {
    case unavailable
}

struct FetchStockUseCase {
    private let operation: (String) async throws -> Stock

    init(repository: any StocksRepository) {
        operation = { symbol in
            try await repository.fetchStock(symbol: symbol)
        }
    }

    init(operation: @escaping (String) async throws -> Stock) {
        self.operation = operation
    }

    func execute(symbol: String) async throws -> Stock {
        try await operation(symbol)
    }
}

extension FetchStockUseCase {
    static let noop = FetchStockUseCase(
        operation: { _ in
            throw FetchStockUseCaseError.unavailable
        }
    )
}
