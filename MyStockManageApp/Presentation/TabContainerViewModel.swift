import SwiftUI

final class TabContainerViewModel: ObservableObject {
    @Published private(set) var selectedTab: StocksTab = .home

    func didSelectTab(_ tab: StocksTab) {
        selectedTab = tab
    }
}
