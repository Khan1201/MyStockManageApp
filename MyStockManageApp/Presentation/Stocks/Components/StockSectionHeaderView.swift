import SwiftUI

struct StockSectionHeaderView: View {
    let title: LocalizedStringResource
    let actionTitle: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Self.primaryColor)

            Spacer()

            Button(action: action) {
                Text(actionTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(0.3)
                    .foregroundStyle(Self.actionColor)
            }
            .buttonStyle(.plain)
        }
    }

    private static let primaryColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let actionColor = Color(red: 1.0, green: 0.41, blue: 0.16)
}
