import SwiftUI

struct CompanyMarkView: View {
    let style: StockLogoStyle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(style.backgroundColor)
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(style.borderColor, lineWidth: 1)

            markContent
        }
        .frame(width: 38, height: 38)
    }

    @ViewBuilder
    private var markContent: some View {
        switch style {
        case .apple:
            Text("A")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        case .amazon:
            Text("a")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.17, green: 0.20, blue: 0.28))
        case .amd:
            Text(">")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.64, blue: 0.44))
        case .adobe:
            Text("A")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.89, green: 0.18, blue: 0.18))
        case .microsoft:
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    markSquare(Color(red: 0.95, green: 0.34, blue: 0.22))
                    markSquare(Color(red: 0.20, green: 0.64, blue: 0.97))
                }
                HStack(spacing: 2) {
                    markSquare(Color(red: 0.49, green: 0.75, blue: 0.18))
                    markSquare(Color(red: 0.98, green: 0.79, blue: 0.16))
                }
            }
        case .tesla:
            Text("T")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 0.72, green: 0.75, blue: 0.80))
        case .nvidia:
            Image(systemName: "eye.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.63, green: 0.87, blue: 0.22))
        case .google:
            Text("G")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
    }

    private func markSquare(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
            .fill(color)
            .frame(width: 7, height: 7)
    }
}
