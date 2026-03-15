import Foundation

struct SearchResultStock: Identifiable, Equatable {
    let symbol: String
    let companyName: String
    let logoStyle: StockLogoStyle

    var id: String { symbol }
}
