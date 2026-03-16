import Foundation

struct EarningsRevenueYearSection: Identifiable {
    let year: Int
    let quarterItems: [EarningsRevenueQuarterItem]

    var id: Int { year }
}
