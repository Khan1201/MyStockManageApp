import Foundation

struct StocksSeedRemoteDataSource: StocksRemoteDataSource {
    func fetchStocksOverview() async throws -> StocksOverviewDTO {
        StocksOverviewDTO(
            portfolio: [
                .init(symbol: "AAPL", companyName: "Apple Inc.", price: 189.43, changePercent: 1.24, brandRawValue: StockBrand.apple.rawValue),
                .init(symbol: "MSFT", companyName: "Microsoft Corp", price: 415.32, changePercent: -0.45, brandRawValue: StockBrand.microsoft.rawValue),
                .init(symbol: "TSLA", companyName: "Tesla, Inc.", price: 175.22, changePercent: 2.15, brandRawValue: StockBrand.tesla.rawValue),
                .init(symbol: "NVDA", companyName: "NVIDIA Corp", price: 875.28, changePercent: 0.82, brandRawValue: StockBrand.nvidia.rawValue),
                .init(symbol: "GOOGL", companyName: "Alphabet Inc.", price: 142.65, changePercent: -1.12, brandRawValue: StockBrand.google.rawValue)
            ],
            searchableStocks: [
                .init(symbol: "AAPL", companyName: "Apple Inc.", brandRawValue: StockBrand.apple.rawValue),
                .init(symbol: "AMZN", companyName: "Amazon.com, Inc.", brandRawValue: StockBrand.amazon.rawValue),
                .init(symbol: "AMD", companyName: "Advanced Micro Devices, Inc.", brandRawValue: StockBrand.amd.rawValue),
                .init(symbol: "ADBE", companyName: "Adobe Inc.", brandRawValue: StockBrand.adobe.rawValue)
            ]
        )
    }

    func fetchStockInsights(for stock: StockDTO) async throws -> StockInsightsDTO {
        switch stock.symbol {
        case "AAPL":
            return StockInsightsDTO(
                forecastSummary: [
                    .init(id: "strong_buy", recommendationRawValue: AnalystRecommendation.strongBuy.rawValue, count: 12),
                    .init(id: "buy", recommendationRawValue: AnalystRecommendation.buy.rawValue, count: 10),
                    .init(id: "hold", recommendationRawValue: AnalystRecommendation.hold.rawValue, count: 6),
                    .init(id: "sell", recommendationRawValue: AnalystRecommendation.sell.rawValue, count: 2),
                    .init(id: "strong_sell", recommendationRawValue: AnalystRecommendation.strongSell.rawValue, count: 0)
                ],
                sentimentSummary: [
                    .init(id: "bullish", signalRawValue: StockMarketSignal.bullish.rawValue, count: 12),
                    .init(id: "bearish", signalRawValue: StockMarketSignal.bearish.rawValue, count: 4)
                ],
                earningsEstimates: [
                    .init(id: "2024_actual", year: 2024, stageRawValue: EstimateStage.actual.rawValue, revenueText: "$383.3B", revenueDeltaText: "-2.1%", revenueDeltaPercent: -2.1, epsText: "$6.13", epsDeltaText: "-1.2%", epsDeltaPercent: -1.2),
                    .init(id: "2025_actual", year: 2025, stageRawValue: EstimateStage.actual.rawValue, revenueText: "$394.3B", revenueDeltaText: "+2.9%", revenueDeltaPercent: 2.9, epsText: "$6.57", epsDeltaText: "+7.2%", epsDeltaPercent: 7.2),
                    .init(id: "2026_est", year: 2026, stageRawValue: EstimateStage.estimated.rawValue, revenueText: "$418.1B", revenueDeltaText: nil, revenueDeltaPercent: nil, epsText: "$7.12", epsDeltaText: nil, epsDeltaPercent: nil),
                    .init(id: "2027_est", year: 2027, stageRawValue: EstimateStage.estimated.rawValue, revenueText: "$442.8B", revenueDeltaText: nil, revenueDeltaPercent: nil, epsText: "$7.85", epsDeltaText: nil, epsDeltaPercent: nil),
                    .init(id: "2028_est", year: 2028, stageRawValue: EstimateStage.estimated.rawValue, revenueText: "$470.2B", revenueDeltaText: nil, revenueDeltaPercent: nil, epsText: "$8.64", epsDeltaText: nil, epsDeltaPercent: nil)
                ]
            )
        case "MSFT":
            return makeGenericStockInsights(
                forecastCounts: [14, 9, 5, 1, 0],
                sentimentCounts: [10, 3],
                estimates: [
                    ("2024_actual", 2024, EstimateStage.actual, "$245.1B", "+15.7%", 15.7, "$11.80", "+22.1%", 22.1),
                    ("2025_est", 2025, EstimateStage.estimated, "$272.8B", nil, nil, "$13.22", nil, nil),
                    ("2026_est", 2026, EstimateStage.estimated, "$298.4B", nil, nil, "$14.66", nil, nil),
                    ("2027_est", 2027, EstimateStage.estimated, "$324.9B", nil, nil, "$16.25", nil, nil)
                ]
            )
        case "TSLA":
            return makeGenericStockInsights(
                forecastCounts: [7, 8, 11, 5, 2],
                sentimentCounts: [8, 9],
                estimates: [
                    ("2024_actual", 2024, EstimateStage.actual, "$97.7B", "+3.4%", 3.4, "$3.12", "-18.4%", -18.4),
                    ("2025_est", 2025, EstimateStage.estimated, "$109.4B", nil, nil, "$3.44", nil, nil),
                    ("2026_est", 2026, EstimateStage.estimated, "$126.8B", nil, nil, "$4.25", nil, nil),
                    ("2027_est", 2027, EstimateStage.estimated, "$142.3B", nil, nil, "$5.08", nil, nil)
                ]
            )
        case "NVDA":
            return makeGenericStockInsights(
                forecastCounts: [16, 12, 4, 1, 0],
                sentimentCounts: [15, 2],
                estimates: [
                    ("2024_actual", 2024, EstimateStage.actual, "$130.5B", "+114.2%", 114.2, "$12.09", "+131.7%", 131.7),
                    ("2025_est", 2025, EstimateStage.estimated, "$164.7B", nil, nil, "$15.01", nil, nil),
                    ("2026_est", 2026, EstimateStage.estimated, "$189.8B", nil, nil, "$17.24", nil, nil),
                    ("2027_est", 2027, EstimateStage.estimated, "$208.6B", nil, nil, "$18.83", nil, nil)
                ]
            )
        case "GOOGL":
            return makeGenericStockInsights(
                forecastCounts: [11, 13, 6, 1, 0],
                sentimentCounts: [11, 3],
                estimates: [
                    ("2024_actual", 2024, EstimateStage.actual, "$350.0B", "+13.5%", 13.5, "$7.89", "+34.6%", 34.6),
                    ("2025_est", 2025, EstimateStage.estimated, "$381.7B", nil, nil, "$8.63", nil, nil),
                    ("2026_est", 2026, EstimateStage.estimated, "$411.9B", nil, nil, "$9.38", nil, nil),
                    ("2027_est", 2027, EstimateStage.estimated, "$439.8B", nil, nil, "$10.11", nil, nil)
                ]
            )
        default:
            return makeGenericStockInsights(
                forecastCounts: [8, 10, 7, 2, 0],
                sentimentCounts: [9, 4],
                estimates: [
                    ("2024_actual", 2024, EstimateStage.actual, "$120.0B", "+5.1%", 5.1, "$4.32", "+8.4%", 8.4),
                    ("2025_est", 2025, EstimateStage.estimated, "$132.4B", nil, nil, "$4.71", nil, nil),
                    ("2026_est", 2026, EstimateStage.estimated, "$145.8B", nil, nil, "$5.08", nil, nil)
                ]
            )
        }
    }

    func fetchAnalystForecasts(for stock: StockDTO) async throws -> AnalystForecastsContentDTO {
        if stock.symbol == "AAPL" {
            return AnalystForecastsContentDTO(
                overview: .init(
                    averageTarget: 202.40,
                    consensusRawValue: AnalystRecommendation.buy.rawValue,
                    analystsCount: 24
                ),
                forecasts: [
                    .init(id: "goldman_sachs", firmName: "Goldman Sachs", analystName: "Jane Doe", ratingRawValue: AnalystRecommendation.strongBuy.rawValue, score: 4.8, dateText: "26/03/15", priceTarget: 210),
                    .init(id: "barclays", firmName: "Barclays", analystName: "David Chen", ratingRawValue: AnalystRecommendation.buy.rawValue, score: 4.5, dateText: "26/03/08", priceTarget: 208),
                    .init(id: "morgan_stanley", firmName: "Morgan Stanley", analystName: "John Smith", ratingRawValue: AnalystRecommendation.buy.rawValue, score: 4.2, dateText: "26/03/12", priceTarget: 205),
                    .init(id: "jp_morgan", firmName: "J.P. Morgan", analystName: "Alice Wang", ratingRawValue: AnalystRecommendation.neutral.rawValue, score: 3.8, dateText: "26/03/10", priceTarget: 190),
                    .init(id: "bank_of_america", firmName: "Bank of America", analystName: "Robert Taylor", ratingRawValue: AnalystRecommendation.neutral.rawValue, score: 3.5, dateText: "26/03/01", priceTarget: 195),
                    .init(id: "ubs", firmName: "UBS", analystName: "Sarah Miller", ratingRawValue: AnalystRecommendation.sell.rawValue, score: 2.1, dateText: "26/03/05", priceTarget: 175)
                ]
            )
        }

        let multipliers = [1.10, 1.07, 1.05, 1.00, 0.98, 0.92]
        let scores = [4.7, 4.4, 4.1, 3.7, 3.4, 2.3]
        let firms = [
            ("goldman_sachs", "Goldman Sachs", "Taylor Reed"),
            ("barclays", "Barclays", "Jordan Lee"),
            ("morgan_stanley", "Morgan Stanley", "Sam Patel"),
            ("jp_morgan", "J.P. Morgan", "Casey Kim"),
            ("bank_of_america", "Bank of America", "Alex Brown"),
            ("ubs", "UBS", "Morgan Diaz")
        ]
        let dates = ["26/03/15", "26/03/12", "26/03/10", "26/03/08", "26/03/05", "26/03/01"]
        let forecasts = firms.enumerated().map { index, firm in
            AnalystForecastRecordDTO(
                id: firm.0,
                firmName: firm.1,
                analystName: firm.2,
                ratingRawValue: recommendation(for: scores[index]).rawValue,
                score: scores[index],
                dateText: dates[index],
                priceTarget: stock.price * multipliers[index]
            )
        }
        let averageTarget = forecasts.map(\.priceTarget).reduce(0, +) / Double(forecasts.count)
        let averageScore = scores.reduce(0, +) / Double(scores.count)

        return AnalystForecastsContentDTO(
            overview: .init(
                averageTarget: averageTarget,
                consensusRawValue: recommendation(for: averageScore).rawValue,
                analystsCount: 24
            ),
            forecasts: forecasts
        )
    }

    func fetchMarketSentiment(for stock: StockDTO) async throws -> [SentimentSectionDTO] {
        let leadingHeadline: String
        switch stock.symbol {
        case "NVDA":
            leadingHeadline = "Nvidia shares surge as AI demand reaches new heights across global markets"
        case "TSLA":
            leadingHeadline = "Tesla shares rebound as autonomy roadmap restores confidence among growth investors"
        case "AAPL":
            leadingHeadline = "Apple demand outlook improves as services momentum offsets hardware uncertainty"
        default:
            leadingHeadline = "\(stock.companyName) sentiment improves as investors respond to fresh market catalysts"
        }

        return [
            SentimentSectionDTO(
                id: "today",
                title: "TODAY",
                items: [
                    .init(id: "today_1", headline: leadingHeadline, sourceName: "Bloomberg", publishedAtText: "10:30 AM", signalRawValue: StockMarketSignal.bullish.rawValue),
                    .init(id: "today_2", headline: "Federal Reserve hints at potential interest rate hike in Q4 following inflation data", sourceName: "Reuters", publishedAtText: "09:15 AM", signalRawValue: StockMarketSignal.bearish.rawValue)
                ]
            ),
            SentimentSectionDTO(
                id: "yesterday",
                title: "YESTERDAY",
                items: [
                    .init(id: "yesterday_1", headline: "Tesla Gigafactory expansion approved, boosting long-term production outlook", sourceName: "CNBC", publishedAtText: "4:20 PM", signalRawValue: StockMarketSignal.bullish.rawValue)
                ]
            ),
            SentimentSectionDTO(
                id: "archive",
                title: "26 MAR 2015",
                items: [
                    .init(id: "archive_1", headline: "Oil prices dip as global supply outweighs projected seasonal demand", sourceName: "WSJ", publishedAtText: "11:05 AM", signalRawValue: StockMarketSignal.bearish.rawValue),
                    .init(id: "archive_2", headline: "Tech sector sees massive inflows as venture capital confidence returns", sourceName: "Financial Times", publishedAtText: "08:30 AM", signalRawValue: StockMarketSignal.bullish.rawValue)
                ]
            )
        ]
    }

    func fetchEarningsRevenue(for stock: StockDTO) async throws -> [EarningsYearRecordDTO] {
        if stock.symbol == "AAPL" {
            return [
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
                        makeReportedQuarter(id: "2026_q2", quarter: "Q2 2026", trailingStatusText: "REPORTED JUL 24", revenue: "$12.4B", revenueEstimate: "Est. $12.1B", revenuePerformancePercent: 2.5, eps: "$1.45", epsEstimate: "Est. $1.42", epsPerformancePercent: 2.1),
                        makeReportedQuarter(id: "2026_q1", quarter: "Q1 2026", trailingStatusText: "REPORTED APR 20", revenue: "$11.8B", revenueEstimate: "Est. $11.9B", revenuePerformancePercent: -0.8, eps: "$1.38", epsEstimate: "Est. $1.40", epsPerformancePercent: -1.4)
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
                        trailingStatusText: reportedText(for: quarter),
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
}

private extension StocksSeedRemoteDataSource {
    func makeGenericStockInsights(
        forecastCounts: [Int],
        sentimentCounts: [Int],
        estimates: [(String, Int, EstimateStage, String, String?, Double?, String, String?, Double?)]
    ) -> StockInsightsDTO {
        StockInsightsDTO(
            forecastSummary: [
                .init(id: "strong_buy", recommendationRawValue: AnalystRecommendation.strongBuy.rawValue, count: forecastCounts[0]),
                .init(id: "buy", recommendationRawValue: AnalystRecommendation.buy.rawValue, count: forecastCounts[1]),
                .init(id: "hold", recommendationRawValue: AnalystRecommendation.hold.rawValue, count: forecastCounts[2]),
                .init(id: "sell", recommendationRawValue: AnalystRecommendation.sell.rawValue, count: forecastCounts[3]),
                .init(id: "strong_sell", recommendationRawValue: AnalystRecommendation.strongSell.rawValue, count: forecastCounts[4])
            ],
            sentimentSummary: [
                .init(id: "bullish", signalRawValue: StockMarketSignal.bullish.rawValue, count: sentimentCounts[0]),
                .init(id: "bearish", signalRawValue: StockMarketSignal.bearish.rawValue, count: sentimentCounts[1])
            ],
            earningsEstimates: estimates.map { estimate in
                .init(
                    id: estimate.0,
                    year: estimate.1,
                    stageRawValue: estimate.2.rawValue,
                    revenueText: estimate.3,
                    revenueDeltaText: estimate.4,
                    revenueDeltaPercent: estimate.5,
                    epsText: estimate.6,
                    epsDeltaText: estimate.7,
                    epsDeltaPercent: estimate.8
                )
            }
        )
    }

    func recommendation(for score: Double) -> AnalystRecommendation {
        switch score {
        case 4.6...:
            return .strongBuy
        case 4.0..<4.6:
            return .buy
        case 3.0..<4.0:
            return .neutral
        default:
            return .sell
        }
    }

    func makeYearSection(
        year: Int,
        quarterItems: [EarningsQuarterRecordDTO]
    ) -> EarningsYearRecordDTO {
        EarningsYearRecordDTO(year: year, quarterItems: quarterItems)
    }

    func makeProjectedQuarter(
        id: String,
        quarter: String,
        revenue: String,
        eps: String
    ) -> EarningsQuarterRecordDTO {
        EarningsQuarterRecordDTO(
            id: id,
            quarterTitle: quarter,
            trailingStatusText: "ESTIMATED",
            stateRawValue: "projected",
            revenueValueText: revenue,
            revenueEstimateText: nil,
            revenuePerformancePercent: nil,
            epsValueText: eps,
            epsEstimateText: nil,
            epsPerformancePercent: nil
        )
    }

    func makeReportedQuarter(
        id: String,
        quarter: String,
        trailingStatusText: String,
        revenue: String,
        revenueEstimate: String,
        revenuePerformancePercent: Double,
        eps: String,
        epsEstimate: String,
        epsPerformancePercent: Double
    ) -> EarningsQuarterRecordDTO {
        EarningsQuarterRecordDTO(
            id: id,
            quarterTitle: quarter,
            trailingStatusText: trailingStatusText,
            stateRawValue: quarterState(revenuePerformancePercent: revenuePerformancePercent, epsPerformancePercent: epsPerformancePercent),
            revenueValueText: revenue,
            revenueEstimateText: revenueEstimate,
            revenuePerformancePercent: revenuePerformancePercent,
            epsValueText: eps,
            epsEstimateText: epsEstimate,
            epsPerformancePercent: epsPerformancePercent
        )
    }

    func quarterState(
        revenuePerformancePercent: Double,
        epsPerformancePercent: Double
    ) -> String {
        let didBeatRevenue = revenuePerformancePercent > 0
        let didBeatEPS = epsPerformancePercent > 0

        if didBeatRevenue && didBeatEPS {
            return "beat"
        }

        if didBeatRevenue || didBeatEPS {
            return "partialMiss"
        }

        return "miss"
    }

    func reportedText(for quarter: Int) -> String {
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

    func billionsText(for value: Double) -> String {
        String(format: "$%.2fB", value)
    }

    func priceText(for value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
