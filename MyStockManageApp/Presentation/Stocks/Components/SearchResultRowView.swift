import SwiftUI

struct SearchResultRowView: View {
    let stock: SearchResultStock
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: stock.displaySymbol)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                    Text(verbatim: stock.companyName)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.56, green: 0.61, blue: 0.71))
                }

                Spacer()

                if stock.type.isEmpty == false {
                    Text(verbatim: stock.type)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.56, green: 0.61, blue: 0.71))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.94, green: 0.96, blue: 0.99))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.69, green: 0.74, blue: 0.82))
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
