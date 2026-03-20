import Foundation

enum EarningsQuarterState: Equatable, Sendable {
    case beat
    case partialMiss
    case miss
    case projected
}

struct EarningsQuarterRecord: Identifiable, Equatable, Sendable {
    let id: String
    let quarterTitle: String
    let trailingStatusText: String
    let state: EarningsQuarterState
    let revenueValueText: String
    let revenueEstimateText: String?
    let revenuePerformancePercent: Double?
    let epsValueText: String
    let epsEstimateText: String?
    let epsPerformancePercent: Double?
}

struct EarningsYearRecord: Identifiable, Equatable, Sendable {
    let year: Int
    let quarterItems: [EarningsQuarterRecord]

    var id: Int { year }
}
