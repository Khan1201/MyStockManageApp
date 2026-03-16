import SwiftUI

struct CenteredBackNavigationBarView: View {
    let title: LocalizedStringResource
    let backAction: () -> Void

    var body: some View {
        HStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Self.backIconColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(Self.titleColor)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
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

    private static let titleColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let backIconColor = Color.black.opacity(0.88)
}
