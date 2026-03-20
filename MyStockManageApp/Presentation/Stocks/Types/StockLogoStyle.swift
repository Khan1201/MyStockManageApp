import SwiftUI

typealias StockLogoStyle = StockBrand

extension StockLogoStyle {
    var backgroundColor: Color {
        switch self {
        case .apple:
            return Color(red: 0.95, green: 0.87, blue: 0.76)
        case .amazon, .amd, .adobe:
            return .white
        case .microsoft:
            return .white
        case .tesla:
            return .white
        case .nvidia:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .google:
            return Color(red: 0.78, green: 0.75, blue: 0.69)
        }
    }

    var borderColor: Color {
        switch self {
        case .apple, .google:
            return .clear
        case .amazon, .amd, .adobe, .microsoft, .tesla:
            return Color(red: 0.93, green: 0.95, blue: 0.98)
        case .nvidia:
            return .clear
        }
    }
}
