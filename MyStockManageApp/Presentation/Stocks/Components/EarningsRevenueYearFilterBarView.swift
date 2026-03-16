import SwiftUI

struct EarningsRevenueYearFilterBarView: View {
    let years: [Int]
    let selectedYear: Int
    let action: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(years, id: \.self) { year in
                    Button {
                        action(year)
                    } label: {
                        Text(verbatim: "\(year)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(year == selectedYear ? Color.white : Self.unselectedTextColor)
                            .padding(.horizontal, 18)
                            .frame(height: 36)
                            .background(
                                Capsule()
                                    .fill(year == selectedYear ? Self.selectedBackgroundColor : Self.unselectedBackgroundColor)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private static let selectedBackgroundColor = Color(red: 0.97, green: 0.43, blue: 0.13)
    private static let unselectedBackgroundColor = Color(red: 0.90, green: 0.92, blue: 0.95)
    private static let unselectedTextColor = Color(red: 0.51, green: 0.58, blue: 0.69)
}
