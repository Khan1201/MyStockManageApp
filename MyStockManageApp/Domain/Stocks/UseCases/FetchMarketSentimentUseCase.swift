import Foundation

struct FetchMarketSentimentUseCase {
    private let operation: (Stock) async throws -> [SentimentSection]

    init(repository: any StocksRepository) {
        operation = { stock in
            try await repository.fetchMarketSentiment(for: stock)
        }
    }

    init(operation: @escaping (Stock) async throws -> [SentimentSection]) {
        self.operation = operation
    }

    func execute(stock: Stock) async throws -> [SentimentSection] {
        try await operation(stock)
    }
}

extension FetchMarketSentimentUseCase {
    static let noop = FetchMarketSentimentUseCase(operation: { _ in [] })
}
