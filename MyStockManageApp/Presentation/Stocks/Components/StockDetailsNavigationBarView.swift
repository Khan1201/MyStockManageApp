import SwiftUI

struct StockDetailsNavigationBarView: View {
    let title: LocalizedStringResource
    let closeAction: () -> Void
    let addAction: () -> Void
    let addButtonSymbolName: String
    let addButtonAccessibilityLabel: LocalizedStringResource

    var body: some View {
        HStack {
            Button(action: closeAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Self.primaryColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(Self.primaryColor)

            Spacer()

            Button(action: addAction) {
                Image(systemName: addButtonSymbolName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Self.actionColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(addButtonAccessibilityLabel))
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(red: 0.90, green: 0.88, blue: 0.87))
                .frame(height: 1)
        }
    }

    private static let primaryColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let actionColor = Color(red: 1.0, green: 0.41, blue: 0.16)
}
