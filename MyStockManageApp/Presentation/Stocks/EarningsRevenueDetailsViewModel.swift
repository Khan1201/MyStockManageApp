import Foundation
import SwiftUI

@MainActor
final class EarningsRevenueDetailsViewModel: ObservableObject {
    @Published private(set) var selectedYear: Int
    @Published private(set) var yearSections: [EarningsRevenueYearSection]

    let stock: PortfolioStock
    let currentFiscalYear: Int

    private let fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase
    private let dismissAction: () -> Void

    init(
        stock: PortfolioStock,
        currentYear: Int = Calendar.autoupdatingCurrent.component(.year, from: Date()),
        fetchEarningsRevenueUseCase: FetchEarningsRevenueUseCase = .noop,
        dismissAction: @escaping () -> Void = {}
    ) {
        self.stock = stock
        self.currentFiscalYear = currentYear
        self.fetchEarningsRevenueUseCase = fetchEarningsRevenueUseCase
        self.dismissAction = dismissAction
        self.yearSections = []
        self.selectedYear = currentYear
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

    func loadEarningsRevenue() async {
        do {
            let records = try await fetchEarningsRevenueUseCase.execute(stock: stock)
            yearSections = records.map {
                EarningsRevenueYearSection(
                    year: $0.year,
                    quarterItems: $0.quarterItems.map(Self.makeQuarterItem)
                )
            }
            selectedYear = Self.initialSelectedYear(from: yearSections.map(\.year), currentYear: currentFiscalYear)
        } catch {
            yearSections = []
            selectedYear = currentFiscalYear
        }
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

    static func makeQuarterItem(_ record: EarningsQuarterRecord) -> EarningsRevenueQuarterItem {
        EarningsRevenueQuarterItem(
            id: record.id,
            quarterTitle: record.quarterTitle,
            trailingStatusText: record.trailingStatusText,
            state: record.state,
            revenueValueText: record.revenueValueText,
            revenueEstimateText: record.revenueEstimateText,
            revenuePerformanceText: performanceText(for: record.revenuePerformancePercent),
            revenuePerformanceColor: performanceColor(for: record.revenuePerformancePercent),
            epsValueText: record.epsValueText,
            epsEstimateText: record.epsEstimateText,
            epsPerformanceText: performanceText(for: record.epsPerformancePercent),
            epsPerformanceColor: performanceColor(for: record.epsPerformancePercent)
        )
    }

    static func performanceText(for percent: Double?) -> String? {
        guard let percent else {
            return nil
        }

        let sign = percent >= 0 ? "+" : ""
        let suffix = percent >= 0 ? "beat" : "miss"
        return "\(sign)\(String(format: "%.1f", percent))% \(suffix)"
    }

    static func performanceColor(for percent: Double?) -> Color? {
        guard let percent else {
            return nil
        }

        return percent >= 0
            ? Color(red: 0.12, green: 0.72, blue: 0.45)
            : Color(red: 0.94, green: 0.24, blue: 0.36)
    }
}
