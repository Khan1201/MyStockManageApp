import Foundation

struct FetchAnalystForecastsUseCase {
    private let operation: (Stock) async throws -> AnalystForecastsContent

    init(repository: any StocksRepository) {
        operation = { stock in
            try await repository.fetchAnalystForecasts(for: stock)
        }
    }

    init(operation: @escaping (Stock) async throws -> AnalystForecastsContent) {
        self.operation = operation
    }

    func execute(stock: Stock) async throws -> AnalystForecastsContent {
        try await operation(stock)
    }
}

extension FetchAnalystForecastsUseCase {
    static let noop = FetchAnalystForecastsUseCase(
        operation: { _ in
            AnalystForecastsContent(
                overview: AnalystForecastOverview(
                    averageTarget: 0,
                    consensus: .neutral,
                    analystsCount: 0
                ),
                forecasts: []
            )
        }
    )
}
