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

    var id: String { symbol }
}

struct StockSearchResult: Identifiable, Equatable, Sendable {
    let symbol: String
    let companyName: String
    let brand: StockBrand

    var id: String { symbol }
}

struct StocksOverview: Equatable, Sendable {
    let portfolio: [Stock]
    let searchableStocks: [StockSearchResult]
}
