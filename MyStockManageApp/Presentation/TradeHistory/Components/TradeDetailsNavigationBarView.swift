import SwiftUI

struct TradeDetailsNavigationBarView: View {
    let title: LocalizedStringResource
    let editTitle: LocalizedStringResource
    let backAction: () -> Void
    let editAction: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(Self.titleColor)

            HStack {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.88))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: editAction) {
                    Text(editTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Self.editColor)
                        .frame(minWidth: 52, alignment: .trailing)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 6)
        .padding(.bottom, 12)
        .background(.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(red: 0.91, green: 0.89, blue: 0.88))
                .frame(height: 1)
        }
    }

    private static let titleColor = Color(red: 0.12, green: 0.16, blue: 0.28)
    private static let editColor = Color(red: 0.98, green: 0.41, blue: 0.07)
}
