import SwiftUI

struct TradeEditorFieldRowView<TrailingContent: View>: View {
    let iconName: String
    let iconForeground: Color
    let iconBackground: Color
    let title: LocalizedStringResource
    @ViewBuilder let trailingContent: () -> TrailingContent

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 30, height: 30)

                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconForeground)
            }

            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.25, green: 0.30, blue: 0.40))

            Spacer(minLength: 12)

            trailingContent()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 3)
    }
}
