import SwiftUI

struct TradeDetailsStatusBadgeView: View {
    let title: LocalizedStringResource
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor, in: Capsule())
    }
}
