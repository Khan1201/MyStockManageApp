import SwiftUI

struct PortfolioRowView: View {
    let stock: PortfolioStock
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CompanyMarkView(imageURL: stock.logoURL)

                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.symbol)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                    Text(verbatim: stock.companyName)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.56, green: 0.61, blue: 0.71))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(verbatim: stock.priceText)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                    Text(verbatim: stock.changeText)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(stock.changeDirection.foregroundColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(stock.changeDirection.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
