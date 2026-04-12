import SwiftUI

struct SearchResultRowView: View {
    let stock: SearchResultStock
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

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.69, green: 0.74, blue: 0.82))
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
