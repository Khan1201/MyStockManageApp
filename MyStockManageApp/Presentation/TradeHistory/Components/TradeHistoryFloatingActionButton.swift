import SwiftUI

struct TradeHistoryFloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(Color(red: 0.98, green: 0.41, blue: 0.07))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.18), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
