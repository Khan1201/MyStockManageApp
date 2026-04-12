import Foundation

typealias PortfolioStock = Stock

extension PortfolioStock {
    var priceText: String {
        String(format: "$%.2f", price)
    }

    var changeText: String {
        String(format: "%@%.2f%%", changePercent >= 0 ? "+" : "", changePercent)
    }

    var changeDirection: StockChangeDirection {
        changePercent >= 0 ? .gain : .loss
    }
}
