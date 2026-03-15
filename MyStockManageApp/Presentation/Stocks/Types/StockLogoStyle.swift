import SwiftUI

enum StockLogoStyle: Equatable {
    case apple
    case amazon
    case amd
    case adobe
    case microsoft
    case tesla
    case nvidia
    case google

    var backgroundColor: Color {
        switch self {
        case .apple:
            return Color(red: 0.95, green: 0.87, blue: 0.76)
        case .amazon, .amd, .adobe:
            return Color.white
        case .microsoft:
            return Color.white
        case .tesla:
            return Color.white
        case .nvidia:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .google:
            return Color(red: 0.78, green: 0.75, blue: 0.69)
        }
    }

    var borderColor: Color {
        switch self {
        case .apple, .google:
            return Color.clear
        case .amazon, .amd, .adobe, .microsoft, .tesla:
            return Color(red: 0.93, green: 0.95, blue: 0.98)
        case .nvidia:
            return Color.clear
        }
    }
}
