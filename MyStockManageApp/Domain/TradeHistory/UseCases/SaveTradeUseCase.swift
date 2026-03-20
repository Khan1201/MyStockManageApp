import Foundation

struct SaveTradeUseCase {
    private let operation: (TradeRecord) async throws -> Void

    init(repository: any TradeHistoryRepository) {
        operation = { trade in
            try await repository.saveTrade(trade)
        }
    }

    init(operation: @escaping (TradeRecord) async throws -> Void) {
        self.operation = operation
    }

    func execute(_ trade: TradeRecord) async throws {
        try await operation(trade)
    }
}

extension SaveTradeUseCase {
    static let noop = SaveTradeUseCase(operation: { _ in })
}
