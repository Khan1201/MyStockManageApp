import Foundation

struct Stock: Identifiable, Equatable, Sendable {
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let logoURL: URL?

    init(
        symbol: String,
        companyName: String,
        price: Double,
        changePercent: Double,
        logoURL: URL? = nil
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.price = price
        self.changePercent = changePercent
        self.logoURL = logoURL
    }

    var id: String { symbol }
}

struct StockSearchResult: Identifiable, Equatable, Sendable {
    let symbol: String
    let displaySymbol: String
    let companyName: String
    let type: String

    init(
        symbol: String,
        displaySymbol: String,
        companyName: String,
        type: String
    ) {
        self.symbol = symbol
        self.displaySymbol = displaySymbol
        self.companyName = companyName
        self.type = type
    }

    var id: String { symbol }
}

struct StocksOverview: Equatable, Sendable {
    let portfolio: [Stock]
}
