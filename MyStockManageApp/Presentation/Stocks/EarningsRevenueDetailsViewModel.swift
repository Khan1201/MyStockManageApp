import Foundation
import SwiftUI

final class EarningsRevenueDetailsViewModel: ObservableObject {
    @Published private(set) var selectedYear: Int

    let yearSections: [EarningsRevenueYearSection]
    let currentFiscalYear: Int

    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        currentYear: Int = Calendar.autoupdatingCurrent.component(.year, from: Date()),
        dismissAction: @escaping () -> Void = {}
    ) {
        yearSections = Self.content(for: stock)
        currentFiscalYear = currentYear
        selectedYear = Self.initialSelectedYear(from: yearSections.map(\.year), currentYear: currentYear)
        self.dismissAction = dismissAction
    }

    var yearCategories: [Int] {
        yearSections.map(\.year).sorted(by: >)
    }

    var selectedYearText: String {
        "\(selectedYear)"
    }

    var isCurrentFiscalYearSelected: Bool {
        selectedYear == currentFiscalYear
    }

    var quarterItems: [EarningsRevenueQuarterItem] {
        yearSections.first(where: { $0.year == selectedYear })?.quarterItems ?? []
    }

    func didTapBackButton() {
        dismissAction()
    }

    func didSelectYear(_ year: Int) {
        guard yearCategories.contains(year) else {
            return
        }

        selectedYear = year
    }
}

private extension EarningsRevenueDetailsViewModel {
    static func initialSelectedYear(from availableYears: [Int], currentYear: Int) -> Int {
        guard !availableYears.isEmpty else {
            return currentYear
        }

        if availableYears.contains(currentYear) {
            return currentYear
        }

        return availableYears.sorted(by: >).first ?? currentYear
    }

    static func content(for stock: PortfolioStock) -> [EarningsRevenueYearSection] {
        switch stock.symbol {
        case "AAPL":
            return appleContent()
        default:
            return genericContent(for: stock)
        }
    }

    static func appleContent() -> [EarningsRevenueYearSection] {
        [
            makeYearSection(
                year: 2028,
                quarterItems: [
                    makeProjectedQuarter(id: "2028_q4", quarter: "Q4 2028", revenue: "$16.90B", eps: "$1.98"),
                    makeProjectedQuarter(id: "2028_q3", quarter: "Q3 2028", revenue: "$16.35B", eps: "$1.92"),
                    makeProjectedQuarter(id: "2028_q2", quarter: "Q2 2028", revenue: "$15.80B", eps: "$1.86"),
                    makeProjectedQuarter(id: "2028_q1", quarter: "Q1 2028", revenue: "$15.10B", eps: "$1.79")
                ]
            ),
            makeYearSection(
                year: 2027,
                quarterItems: [
                    makeProjectedQuarter(id: "2027_q4", quarter: "Q4 2027", revenue: "$15.60B", eps: "$1.86"),
                    makeProjectedQuarter(id: "2027_q3", quarter: "Q3 2027", revenue: "$14.90B", eps: "$1.78"),
                    makeProjectedQuarter(id: "2027_q2", quarter: "Q2 2027", revenue: "$14.40B", eps: "$1.71"),
                    makeProjectedQuarter(id: "2027_q1", quarter: "Q1 2027", revenue: "$13.95B", eps: "$1.67")
                ]
            ),
            makeYearSection(
                year: 2026,
                quarterItems: [
                    makeProjectedQuarter(id: "2026_q4", quarter: "Q4 2026", revenue: "$13.85B", eps: "$1.62"),
                    makeProjectedQuarter(id: "2026_q3", quarter: "Q3 2026", revenue: "$13.10B", eps: "$1.55"),
                    makeReportedQuarter(
                        id: "2026_q2",
                        quarter: "Q2 2026",
                        trailingStatusText: "REPORTED JUL 24",
                        revenue: "$12.4B",
                        revenueEstimate: "Est. $12.1B",
                        revenuePerformancePercent: 2.5,
                        eps: "$1.45",
                        epsEstimate: "Est. $1.42",
                        epsPerformancePercent: 2.1
                    ),
                    makeReportedQuarter(
                        id: "2026_q1",
                        quarter: "Q1 2026",
                        trailingStatusText: "REPORTED APR 20",
                        revenue: "$11.8B",
                        revenueEstimate: "Est. $11.9B",
                        revenuePerformancePercent: -0.8,
                        eps: "$1.38",
                        epsEstimate: "Est. $1.40",
                        epsPerformancePercent: -1.4
                    )
                ]
            ),
            makeYearSection(
                year: 2025,
                quarterItems: [
                    makeReportedQuarter(id: "2025_q4", quarter: "Q4 2025", trailingStatusText: "REPORTED OCT 28", revenue: "$12.8B", revenueEstimate: "Est. $12.4B", revenuePerformancePercent: 3.2, eps: "$1.49", epsEstimate: "Est. $1.44", epsPerformancePercent: 3.5),
                    makeReportedQuarter(id: "2025_q3", quarter: "Q3 2025", trailingStatusText: "REPORTED JUL 25", revenue: "$12.1B", revenueEstimate: "Est. $12.0B", revenuePerformancePercent: 0.8, eps: "$1.41", epsEstimate: "Est. $1.39", epsPerformancePercent: 1.4),
                    makeReportedQuarter(id: "2025_q2", quarter: "Q2 2025", trailingStatusText: "REPORTED APR 24", revenue: "$11.7B", revenueEstimate: "Est. $11.6B", revenuePerformancePercent: 0.9, eps: "$1.36", epsEstimate: "Est. $1.38", epsPerformancePercent: -1.4),
                    makeReportedQuarter(id: "2025_q1", quarter: "Q1 2025", trailingStatusText: "REPORTED JAN 23", revenue: "$11.2B", revenueEstimate: "Est. $11.3B", revenuePerformancePercent: -0.8, eps: "$1.30", epsEstimate: "Est. $1.31", epsPerformancePercent: -0.8)
                ]
            ),
            makeYearSection(
                year: 2024,
                quarterItems: [
                    makeReportedQuarter(id: "2024_q4", quarter: "Q4 2024", trailingStatusText: "REPORTED OCT 29", revenue: "$11.9B", revenueEstimate: "Est. $11.6B", revenuePerformancePercent: 2.6, eps: "$1.33", epsEstimate: "Est. $1.29", epsPerformancePercent: 3.1),
                    makeReportedQuarter(id: "2024_q3", quarter: "Q3 2024", trailingStatusText: "REPORTED JUL 25", revenue: "$11.4B", revenueEstimate: "Est. $11.2B", revenuePerformancePercent: 1.8, eps: "$1.28", epsEstimate: "Est. $1.25", epsPerformancePercent: 2.4),
                    makeReportedQuarter(id: "2024_q2", quarter: "Q2 2024", trailingStatusText: "REPORTED APR 25", revenue: "$10.9B", revenueEstimate: "Est. $11.0B", revenuePerformancePercent: -0.9, eps: "$1.21", epsEstimate: "Est. $1.22", epsPerformancePercent: -0.8),
                    makeReportedQuarter(id: "2024_q1", quarter: "Q1 2024", trailingStatusText: "REPORTED JAN 25", revenue: "$10.5B", revenueEstimate: "Est. $10.4B", revenuePerformancePercent: 1.0, eps: "$1.18", epsEstimate: "Est. $1.16", epsPerformancePercent: 1.7)
                ]
            )
        ]
    }

    static func genericContent(for stock: PortfolioStock) -> [EarningsRevenueYearSection] {
        let years = [2028, 2027, 2026, 2025, 2024]
        let baseRevenue = max(stock.price / 14, 4.2)
        let baseEPS = max(stock.price / 180, 0.85)

        return years.map { year in
            let yearOffset = Double(year - 2024)

            return makeYearSection(
                year: year,
                quarterItems: [4, 3, 2, 1].map { quarter in
                    let quarterOffset = Double(quarter - 1) * 0.22
                    let revenue = baseRevenue + yearOffset * 0.65 + quarterOffset
                    let eps = baseEPS + yearOffset * 0.08 + quarterOffset * 0.12

                    if year >= 2026 {
                        return makeProjectedQuarter(
                            id: "\(year)_q\(quarter)",
                            quarter: "Q\(quarter) \(year)",
                            revenue: billionsText(for: revenue),
                            eps: priceText(for: eps)
                        )
                    }

                    let didBeat = quarter != 1
                    let revenuePerformance = didBeat ? 1.8 : -1.1
                    let epsPerformance = quarter == 2 ? -0.9 : (didBeat ? 2.1 : -1.4)
                    let revenueEstimateValue = revenue / (1 + (revenuePerformance / 100))
                    let epsEstimateValue = eps / (1 + (epsPerformance / 100))

                    return makeReportedQuarter(
                        id: "\(year)_q\(quarter)",
                        quarter: "Q\(quarter) \(year)",
                        trailingStatusText: reportedText(for: year, quarter: quarter),
                        revenue: billionsText(for: revenue),
                        revenueEstimate: "Est. \(billionsText(for: revenueEstimateValue))",
                        revenuePerformancePercent: revenuePerformance,
                        eps: priceText(for: eps),
                        epsEstimate: "Est. \(priceText(for: epsEstimateValue))",
                        epsPerformancePercent: epsPerformance
                    )
                }
            )
        }
    }

    static func makeYearSection(
        year: Int,
        quarterItems: [EarningsRevenueQuarterItem]
    ) -> EarningsRevenueYearSection {
        EarningsRevenueYearSection(year: year, quarterItems: quarterItems)
    }

    static func makeProjectedQuarter(
        id: String,
        quarter: String,
        revenue: String,
        eps: String
    ) -> EarningsRevenueQuarterItem {
        EarningsRevenueQuarterItem(
            id: id,
            quarterTitle: quarter,
            trailingStatusText: "ESTIMATED",
            state: .projected,
            revenueValueText: revenue,
            revenueEstimateText: nil,
            revenuePerformanceText: nil,
            revenuePerformanceColor: nil,
            epsValueText: eps,
            epsEstimateText: nil,
            epsPerformanceText: nil,
            epsPerformanceColor: nil
        )
    }

    static func makeReportedQuarter(
        id: String,
        quarter: String,
        trailingStatusText: String,
        revenue: String,
        revenueEstimate: String,
        revenuePerformancePercent: Double,
        eps: String,
        epsEstimate: String,
        epsPerformancePercent: Double
    ) -> EarningsRevenueQuarterItem {
        let quarterState = state(
            revenuePerformancePercent: revenuePerformancePercent,
            epsPerformancePercent: epsPerformancePercent
        )

        return EarningsRevenueQuarterItem(
            id: id,
            quarterTitle: quarter,
            trailingStatusText: trailingStatusText,
            state: quarterState,
            revenueValueText: revenue,
            revenueEstimateText: revenueEstimate,
            revenuePerformanceText: performanceText(for: revenuePerformancePercent),
            revenuePerformanceColor: performanceColor(for: revenuePerformancePercent),
            epsValueText: eps,
            epsEstimateText: epsEstimate,
            epsPerformanceText: performanceText(for: epsPerformancePercent),
            epsPerformanceColor: performanceColor(for: epsPerformancePercent)
        )
    }

    static func reportedText(for _: Int, quarter: Int) -> String {
        switch quarter {
        case 4:
            return "REPORTED OCT 28"
        case 3:
            return "REPORTED JUL 24"
        case 2:
            return "REPORTED APR 25"
        default:
            return "REPORTED JAN 24"
        }
    }

    static func billionsText(for value: Double) -> String {
        String(format: "$%.2fB", value)
    }

    static func priceText(for value: Double) -> String {
        String(format: "$%.2f", value)
    }

    static func performanceText(for percent: Double) -> String {
        let sign = percent >= 0 ? "+" : ""
        let suffix = percent >= 0 ? "beat" : "miss"
        return "\(sign)\(String(format: "%.1f", percent))% \(suffix)"
    }

    static func performanceColor(for percent: Double) -> Color {
        percent >= 0
            ? Color(red: 0.12, green: 0.72, blue: 0.45)
            : Color(red: 0.94, green: 0.24, blue: 0.36)
    }

    static func state(
        revenuePerformancePercent: Double,
        epsPerformancePercent: Double
    ) -> EarningsRevenueQuarterState {
        let didBeatRevenue = revenuePerformancePercent > 0
        let didBeatEPS = epsPerformancePercent > 0

        if didBeatRevenue && didBeatEPS {
            return .beat
        }

        if didBeatRevenue || didBeatEPS {
            return .partialMiss
        }

        return .miss
    }
}
