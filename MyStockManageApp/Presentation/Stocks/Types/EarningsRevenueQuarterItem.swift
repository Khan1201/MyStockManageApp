import SwiftUI

struct EarningsRevenueQuarterItem: Identifiable {
    let id: String
    let quarterTitle: String
    let trailingStatusText: String
    let state: EarningsRevenueQuarterState
    let revenueValueText: String
    let revenueEstimateText: String?
    let revenuePerformanceText: String?
    let revenuePerformanceColor: Color?
    let epsValueText: String
    let epsEstimateText: String?
    let epsPerformanceText: String?
    let epsPerformanceColor: Color?
}
