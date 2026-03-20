import Foundation

typealias SearchResultStock = StockSearchResult

extension SearchResultStock {
    init(
        symbol: String,
        companyName: String,
        logoStyle: StockLogoStyle
    ) {
        self.init(symbol: symbol, companyName: companyName, brand: logoStyle)
    }

    var logoStyle: StockLogoStyle {
        brand
    }
}
