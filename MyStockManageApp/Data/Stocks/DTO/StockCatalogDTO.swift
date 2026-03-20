import Foundation

struct StockDTO: Equatable, Sendable {
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let brandRawValue: String

    init(
        symbol: String,
        companyName: String,
        price: Double,
        changePercent: Double,
        brandRawValue: String
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.price = price
        self.changePercent = changePercent
        self.brandRawValue = brandRawValue
    }

    init(stock: Stock) {
        self.init(
            symbol: stock.symbol,
            companyName: stock.companyName,
            price: stock.price,
            changePercent: stock.changePercent,
            brandRawValue: stock.brand.rawValue
        )
    }

    func toDomain() throws -> Stock {
        guard let brand = StockBrand(rawValue: brandRawValue) else {
            throw StocksDTOError.invalidBrand(brandRawValue)
        }

        return Stock(
            symbol: symbol,
            companyName: companyName,
            price: price,
            changePercent: changePercent,
            brand: brand
        )
    }
}

struct StockSearchResultDTO: Equatable, Sendable {
    let symbol: String
    let companyName: String
    let brandRawValue: String

    func toDomain() throws -> StockSearchResult {
        guard let brand = StockBrand(rawValue: brandRawValue) else {
            throw StocksDTOError.invalidBrand(brandRawValue)
        }

        return StockSearchResult(symbol: symbol, companyName: companyName, brand: brand)
    }
}

struct StocksOverviewDTO: Equatable, Sendable {
    let portfolio: [StockDTO]
    let searchableStocks: [StockSearchResultDTO]

    func toDomain() throws -> StocksOverview {
        try StocksOverview(
            portfolio: portfolio.map { try $0.toDomain() },
            searchableStocks: searchableStocks.map { try $0.toDomain() }
        )
    }
}
