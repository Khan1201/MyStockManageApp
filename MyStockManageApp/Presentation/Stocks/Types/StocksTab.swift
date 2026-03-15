import Foundation

enum StocksTab: String, CaseIterable, Identifiable {
    case home
    case history
    case rules
    case quotes

    var id: String { rawValue }
}
