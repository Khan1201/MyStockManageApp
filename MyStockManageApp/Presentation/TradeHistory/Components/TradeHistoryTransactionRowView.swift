import SwiftUI

struct TradeHistoryTransactionRowView: View {
    let transaction: TradeHistoryTransaction
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.transactionType.tintColor)
                    .frame(width: 34, height: 34)

                Text(verbatim: transaction.transactionType.badgeTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: transaction.symbol)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.12, green: 0.16, blue: 0.28))

                Text(verbatim: transaction.subtitleText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.49, green: 0.55, blue: 0.67))
            }

            Spacer()

            Text(transaction.transactionType.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.transactionType.tintColor)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color(red: 0.93, green: 0.94, blue: 0.97))
                    .frame(height: 1)
                    .padding(.leading, 46)
            }
        }
    }
}
