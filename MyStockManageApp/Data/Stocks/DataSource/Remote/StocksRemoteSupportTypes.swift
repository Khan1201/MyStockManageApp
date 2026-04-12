import Foundation

struct SupportedStockDescriptor: Sendable {
    let symbol: String
    let companyName: String

    static let portfolioDescriptors: [SupportedStockDescriptor] = [
        .init(symbol: "AAPL", companyName: "Apple Inc."),
        .init(symbol: "MSFT", companyName: "Microsoft Corp"),
        .init(symbol: "TSLA", companyName: "Tesla, Inc."),
        .init(symbol: "NVDA", companyName: "NVIDIA Corp"),
        .init(symbol: "GOOGL", companyName: "Alphabet Inc.")
    ]
}

struct IndexedStockOverviewPayload: Sendable {
    let index: Int
    let stock: StockOverviewRemotePayload
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
    let article: SentimentArticleRemoteModel
    let signal: StockMarketSignal

    var date: Date {
        Date(timeIntervalSince1970: article.datetime)
    }
}

enum CurrencyScale {
    case plain
    case billions
}
