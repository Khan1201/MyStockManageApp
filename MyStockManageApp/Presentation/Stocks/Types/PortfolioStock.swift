import Foundation

typealias PortfolioStock = Stock

extension PortfolioStock {
    init(
        symbol: String,
        companyName: String,
        price: Double,
        changePercent: Double,
        logoStyle: StockLogoStyle
    ) {
        self.init(
            symbol: symbol,
            companyName: companyName,
            price: price,
            changePercent: changePercent,
            brand: logoStyle
        )
    }

    var priceText: String {
        String(format: "$%.2f", price)
    }

    var changeText: String {
        String(format: "%@%.2f%%", changePercent >= 0 ? "+" : "", changePercent)
    }

    var changeDirection: StockChangeDirection {
        changePercent >= 0 ? .gain : .loss
    }

    var logoStyle: StockLogoStyle {
        brand
    }
}
