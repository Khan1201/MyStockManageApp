import Foundation

struct FinnhubErrorDTO: Decodable, Equatable, Sendable {
    let error: String
}

struct FinnhubQuoteDTO: Decodable, Equatable, Sendable {
    let c: Double
    let dp: Double

    var currentPrice: Double { c }
    var changePercent: Double { dp }
}

struct FinnhubProfileDTO: Decodable, Equatable, Sendable {
    let name: String?

    var trimmedName: String? {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

struct FinnhubRecommendationDTO: Decodable, Equatable, Sendable {
    let buy: Int
    let hold: Int
    let period: String
    let sell: Int
    let strongBuy: Int
    let strongSell: Int
}

struct FinnhubPriceTargetDTO: Decodable, Equatable, Sendable {
    let targetHigh: Double?
    let targetLow: Double?
    let targetMean: Double?
    let targetMedian: Double?
}

struct FinnhubNewsDTO: Decodable, Equatable, Sendable {
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let source: String
    let summary: String
}

struct FinnhubEarningsHistoryDTO: Decodable, Equatable, Sendable {
    let actual: Double?
    let estimate: Double?
    let quarter: Int
    let year: Int
}

struct FinnhubEarningsCalendarEnvelopeDTO: Decodable, Equatable, Sendable {
    let earningsCalendar: [FinnhubEarningsCalendarDTO]
}

struct FinnhubEarningsCalendarDTO: Decodable, Equatable, Sendable {
    let date: String
    let epsEstimate: Double?
    let quarter: Int
    let revenueEstimate: Double?
    let year: Int
}

struct FinnhubFinancialReportsEnvelopeDTO: Decodable, Equatable, Sendable {
    let data: [FinnhubFinancialReportDTO]
}

struct FinnhubFinancialReportDTO: Decodable, Equatable, Sendable {
    let filedDate: String
    let quarter: Int
    let report: FinnhubFinancialReportPayloadDTO
    let year: Int
}

struct FinnhubFinancialReportPayloadDTO: Decodable, Equatable, Sendable {
    let ic: [FinnhubFinancialStatementEntryDTO]

    var incomeStatement: FinnhubIncomeStatementDTO {
        FinnhubIncomeStatementDTO(entries: ic)
    }
}

struct FinnhubFinancialStatementEntryDTO: Decodable, Equatable, Sendable {
    let concept: String
    let value: Double?
}

struct FinnhubIncomeStatementDTO: Equatable, Sendable {
    let entries: [FinnhubFinancialStatementEntryDTO]

    var revenueValue: Double? {
        value(
            for: [
                "us-gaap_RevenueFromContractWithCustomerExcludingAssessedTax",
                "us-gaap_SalesRevenueNet"
            ]
        )
    }

    var dilutedEPSValue: Double? {
        value(
            for: [
                "us-gaap_EarningsPerShareDiluted",
                "us-gaap_EarningsPerShareBasic"
            ]
        )
    }

    private func value(for concepts: [String]) -> Double? {
        for concept in concepts {
            if let value = entries.first(where: { $0.concept == concept })?.value {
                return value
            }
        }

        return nil
    }
}
