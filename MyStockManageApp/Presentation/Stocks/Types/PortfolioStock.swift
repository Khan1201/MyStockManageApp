import Foundation

struct PortfolioStock: Identifiable, Equatable {
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let logoStyle: StockLogoStyle

    var id: String { symbol }

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
