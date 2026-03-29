import Foundation

struct SupportedStockDescriptor {
    let symbol: String
    let companyName: String
    let brand: StockBrand
}

struct IndexedPortfolioStockPayload {
    let index: Int
    let stock: PortfolioStockRemotePayload
}

struct QuarterKey: Hashable {
    let year: Int
    let quarter: Int
}

struct QuarterFinancialValue {
    var filedDate: Date?
    var revenueActual: Double?
    var revenueEstimate: Double?
    var epsActual: Double?
    var epsEstimate: Double?
}

struct AnnualFinancialValue {
    let year: Int
    let revenue: Double
    let eps: Double
}

struct ClassifiedSentimentArticle {
    let article: FinnhubNewsDTO
    let signal: StockMarketSignal

    var date: Date {
        Date(timeIntervalSince1970: article.datetime)
    }
}

enum CurrencyScale {
    case plain
    case billions
}
