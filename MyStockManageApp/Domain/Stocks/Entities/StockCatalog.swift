import Foundation

enum StockBrand: String, Equatable, Sendable {
    case apple
    case amazon
    case amd
    case adobe
    case microsoft
    case tesla
    case nvidia
    case google
}

struct Stock: Identifiable, Equatable, Sendable {
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let brand: StockBrand
    let logoURL: URL?

    init(
        symbol: String,
        companyName: String,
        price: Double,
        changePercent: Double,
        brand: StockBrand,
        logoURL: URL? = nil
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.price = price
        self.changePercent = changePercent
        self.brand = brand
        self.logoURL = logoURL
    }

    var id: String { symbol }
}

struct StockSearchResult: Identifiable, Equatable, Sendable {
    let symbol: String
    let companyName: String
    let brand: StockBrand
    let logoURL: URL?

    init(
        symbol: String,
        companyName: String,
        brand: StockBrand,
        logoURL: URL? = nil
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.brand = brand
        self.logoURL = logoURL
    }

    var id: String { symbol }
}

struct StocksOverview: Equatable, Sendable {
    let portfolio: [Stock]
    let searchableStocks: [StockSearchResult]
}
