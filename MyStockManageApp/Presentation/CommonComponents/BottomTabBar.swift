import SwiftUI

struct BottomTabBar: View {
    let selectedTab: StocksTab
    let selectionAction: (StocksTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(StocksTab.allCases) { tab in
                Button {
                    selectionAction(tab)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: iconName(for: tab))
                            .font(.system(size: 18, weight: .semibold))
                        Text(title(for: tab))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(tab == selectedTab ? Color(red: 1.0, green: 0.41, blue: 0.16) : Color(red: 0.62, green: 0.67, blue: 0.76))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(red: 0.90, green: 0.92, blue: 0.96))
                .frame(height: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 14, y: -2)
    }

    private func iconName(for tab: StocksTab) -> String {
        switch tab {
        case .home:
            return "house.fill"
        case .history:
            return "newspaper"
        case .rules:
            return "checklist"
        case .quotes:
            return "quote.bubble.fill"
        }
    }

    private func title(for tab: StocksTab) -> LocalizedStringResource {
        switch tab {
        case .home:
            return "Home"
        case .history:
            return "History"
        case .rules:
            return "Rules"
        case .quotes:
            return "Quotes"
        }
    }
}
