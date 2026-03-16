import SwiftUI

struct StockDetailsHeaderView: View {
    let stock: PortfolioStock
    let priceText: String
    let priceChangeText: String
    let priceChangeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                CompanyMarkView(style: stock.logoStyle)
                    .scaleEffect(1.45)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: stock.companyName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Self.primaryColor)

                    Text(verbatim: stock.symbol)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Self.secondaryColor)
                        .textCase(.uppercase)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(verbatim: priceText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Self.primaryColor)

                Text(verbatim: priceChangeText)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(priceChangeColor)
            }
        }
    }

    private static let primaryColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let secondaryColor = Color(red: 0.56, green: 0.61, blue: 0.71)
}
