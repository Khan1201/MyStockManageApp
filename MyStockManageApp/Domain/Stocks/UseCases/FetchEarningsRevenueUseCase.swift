import Foundation

struct FetchEarningsRevenueUseCase {
    private let operation: (Stock) async throws -> [EarningsYearRecord]

    init(repository: any StocksRepository) {
        operation = { stock in
            try await repository.fetchEarningsRevenue(for: stock)
        }
    }

    init(operation: @escaping (Stock) async throws -> [EarningsYearRecord]) {
        self.operation = operation
    }

    func execute(stock: Stock) async throws -> [EarningsYearRecord] {
        try await operation(stock)
    }
}

extension FetchEarningsRevenueUseCase {
    static let noop = FetchEarningsRevenueUseCase(operation: { _ in [] })
}
