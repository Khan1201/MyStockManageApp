import Foundation

struct FetchTradeHistoryUseCase {
    private let operation: () async throws -> [TradeRecord]

    init(repository: any TradeHistoryRepository) {
        operation = {
            try await repository.fetchTrades()
        }
    }

    init(operation: @escaping () async throws -> [TradeRecord]) {
        self.operation = operation
    }

    func execute() async throws -> [TradeRecord] {
        try await operation()
    }
}

extension FetchTradeHistoryUseCase {
    static let noop = FetchTradeHistoryUseCase(operation: { [] })
}
