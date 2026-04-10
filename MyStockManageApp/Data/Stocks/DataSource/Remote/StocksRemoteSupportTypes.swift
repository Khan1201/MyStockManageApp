import Foundation

struct SupportedStockDescriptor {
    let symbol: String
    let companyName: String
    let brand: StockBrand

    static let portfolioDescriptors: [SupportedStockDescriptor] = [
        .init(symbol: "AAPL", companyName: "Apple Inc.", brand: .apple),
        .init(symbol: "MSFT", companyName: "Microsoft Corp", brand: .microsoft),
        .init(symbol: "TSLA", companyName: "Tesla, Inc.", brand: .tesla),
        .init(symbol: "NVDA", companyName: "NVIDIA Corp", brand: .nvidia),
        .init(symbol: "GOOGL", companyName: "Alphabet Inc.", brand: .google)
    ]

    static let searchableDescriptors: [SupportedStockDescriptor] = [
        .init(symbol: "AAPL", companyName: "Apple Inc.", brand: .apple),
        .init(symbol: "AMZN", companyName: "Amazon.com, Inc.", brand: .amazon),
        .init(symbol: "AMD", companyName: "Advanced Micro Devices, Inc.", brand: .amd),
        .init(symbol: "ADBE", companyName: "Adobe Inc.", brand: .adobe),
        .init(symbol: "MSFT", companyName: "Microsoft Corp", brand: .microsoft),
        .init(symbol: "TSLA", companyName: "Tesla, Inc.", brand: .tesla),
        .init(symbol: "NVDA", companyName: "NVIDIA Corp", brand: .nvidia),
        .init(symbol: "GOOGL", companyName: "Alphabet Inc.", brand: .google)
    ]
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
