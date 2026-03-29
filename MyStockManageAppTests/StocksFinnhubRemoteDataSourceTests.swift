import XCTest
@testable import MyStockManageApp

final class StocksFinnhubRemoteDataSourceTests: XCTestCase {
    func testFetchStocksOverviewBuildsPortfolioPayloadFromLiveQuotes() async throws {
        let sut = makeSUT { request in
            switch try Self.endpoint(for: request) {
            case "quote?symbol=AAPL":
                return Self.jsonData(#"{"c":189.43,"dp":1.31}"#)
            case "stock/profile2?symbol=AAPL":
                return Self.jsonData(#"{"name":"Apple Inc."}"#)
            case "quote?symbol=MSFT":
                return Self.jsonData(#"{"c":415.32,"dp":-0.45}"#)
            case "stock/profile2?symbol=MSFT":
                return Self.jsonData(#"{"name":"Microsoft Corp"}"#)
            case "quote?symbol=TSLA":
                return Self.jsonData(#"{"c":175.22,"dp":2.15}"#)
            case "stock/profile2?symbol=TSLA":
                return Self.jsonData(#"{"name":"Tesla, Inc."}"#)
            case "quote?symbol=NVDA":
                return Self.jsonData(#"{"c":875.28,"dp":0.82}"#)
            case "stock/profile2?symbol=NVDA":
                return Self.jsonData(#"{"name":"NVIDIA Corp"}"#)
            case "quote?symbol=GOOGL":
                return Self.jsonData(#"{"c":142.65,"dp":-1.12}"#)
            case "stock/profile2?symbol=GOOGL":
                return Self.jsonData(#"{"name":"Alphabet Inc."}"#)
            default:
                XCTFail("Unexpected request")
                return Data()
            }
        }

        let overview = try await sut.fetchStocksOverview()

        XCTAssertEqual(overview.count, 5)
        XCTAssertEqual(overview.first?.quote.currentPrice, 189.43)
        XCTAssertEqual(overview.first?.profile?.trimmedName, "Apple Inc.")
    }

    func testFetchStockInsightsReturnsRawPayloads() async throws {
        let sut = makeSUT { request in
            switch try Self.endpoint(for: request) {
            case "stock/recommendation?symbol=AAPL":
                return Self.jsonData(#"[{"buy":10,"hold":6,"period":"2026-03-01","sell":2,"strongBuy":12,"strongSell":0}]"#)
            case "company-news?from=2026-03-15&symbol=AAPL&to=2026-03-29":
                return Self.jsonData(#"[{"datetime":1774751400,"headline":"Apple shares surge after strong AI launch","id":1,"source":"Bloomberg","summary":"Analysts upgrade the stock on improving growth."}]"#)
            case "stock/financials-reported?freq=annual&symbol=AAPL":
                return Self.jsonData(#"{"data":[{"filedDate":"2025-10-31 00:00:00","quarter":0,"year":2025,"report":{"ic":[{"concept":"us-gaap_RevenueFromContractWithCustomerExcludingAssessedTax","value":416161000000},{"concept":"us-gaap_EarningsPerShareDiluted","value":7.46}]}}]}"#)
            case "stock/financials-reported?freq=quarterly&symbol=AAPL":
                return Self.jsonData(#"{"data":[]}"#)
            case "stock/earnings?symbol=AAPL":
                return Self.jsonData(#"[]"#)
            case "calendar/earnings?from=2025-01-01&symbol=AAPL&to=2028-12-31":
                return Self.jsonData(#"{"earningsCalendar":[]}"#)
            default:
                XCTFail("Unexpected request")
                return Data()
            }
        }

        let insights = try await sut.fetchStockInsights(for: makeAppleStock())

        XCTAssertEqual(insights.recommendations.first?.strongBuy, 12)
        XCTAssertEqual(insights.articles.first?.headline, "Apple shares surge after strong AI launch")
        XCTAssertEqual(insights.annualReports.first?.year, 2025)
        XCTAssertEqual(insights.quarterlyReports, [])
    }

    func testFetchAnalystForecastsReturnsRecommendationsAndPriceTargetPayload() async throws {
        let sut = makeSUT { request in
            switch try Self.endpoint(for: request) {
            case "stock/recommendation?symbol=AAPL":
                return Self.jsonData(#"[{"buy":10,"hold":6,"period":"2026-03-01","sell":2,"strongBuy":12,"strongSell":0}]"#)
            case "stock/price-target?symbol=AAPL":
                return Self.jsonData(#"{"targetHigh":220.0,"targetLow":180.0,"targetMean":202.4,"targetMedian":205.0}"#)
            default:
                XCTFail("Unexpected request")
                return Data()
            }
        }

        let content = try await sut.fetchAnalystForecasts(for: makeAppleStock())

        XCTAssertEqual(content.recommendations.first?.buy, 10)
        XCTAssertEqual(content.priceTarget.targetMean, 202.4)
    }

    func testFetchMarketSentimentReturnsNewsDTOs() async throws {
        let sut = makeSUT(now: Self.makeDate("2026-03-29T12:00:00Z")) { request in
            switch try Self.endpoint(for: request) {
            case "company-news?from=2026-03-15&symbol=AAPL&to=2026-03-29":
                return Self.jsonData(#"[{"datetime":1774751400,"headline":"Apple shares surge after strong launch","id":1,"source":"Bloomberg","summary":"Growth upgrade boosts outlook."},{"datetime":1774688400,"headline":"Apple faces lawsuit risk in Europe","id":2,"source":"Reuters","summary":"Pressure on services margins increases."}]"#)
            default:
                XCTFail("Unexpected request")
                return Data()
            }
        }

        let sentiment = try await sut.fetchMarketSentiment(for: makeAppleStock())

        XCTAssertEqual(sentiment.map(\.id), [1, 2])
        XCTAssertEqual(sentiment.first?.source, "Bloomberg")
    }

    func testFetchEarningsRevenueReturnsQuarterlyPayloads() async throws {
        let sut = makeSUT { request in
            switch try Self.endpoint(for: request) {
            case "stock/financials-reported?freq=quarterly&symbol=AAPL":
                return Self.jsonData(#"{"data":[{"filedDate":"2026-01-30 00:00:00","quarter":1,"year":2026,"report":{"ic":[{"concept":"us-gaap_RevenueFromContractWithCustomerExcludingAssessedTax","value":143756000000},{"concept":"us-gaap_EarningsPerShareDiluted","value":2.84}]}}]}"#)
            case "stock/earnings?symbol=AAPL":
                return Self.jsonData(#"[{"actual":2.84,"estimate":2.7257,"quarter":1,"year":2026}]"#)
            case "calendar/earnings?from=2025-01-01&symbol=AAPL&to=2028-12-31":
                return Self.jsonData(#"{"earningsCalendar":[{"date":"2026-04-29","epsEstimate":1.9828,"quarter":2,"revenueEstimate":111468787296,"year":2026}]}"#)
            default:
                XCTFail("Unexpected request")
                return Data()
            }
        }

        let records = try await sut.fetchEarningsRevenue(for: makeAppleStock())

        XCTAssertEqual(records.quarterlyReports.first?.quarter, 1)
        XCTAssertEqual(records.earningsHistory.first?.actual, 2.84)
        XCTAssertEqual(records.earningsCalendar.first?.quarter, 2)
    }

    func testFetchStocksOverviewPropagatesError() async {
        let expectedError = URLError(.notConnectedToInternet)
        let sut = makeSUT { _ in
            throw expectedError
        }

        do {
            _ = try await sut.fetchStocksOverview()
            XCTFail("Expected fetchStocksOverview to throw")
        } catch let error as URLError {
            XCTAssertEqual(error.code, expectedError.code)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private extension StocksFinnhubRemoteDataSourceTests {
    func makeSUT(
        now: Date? = nil,
        handler: @escaping @Sendable (URLRequest) throws -> Data
    ) -> StocksFinnhubRemoteDataSource {
        let resolvedNow = now ?? Self.makeDate("2026-03-29T12:00:00Z")

        return StocksFinnhubRemoteDataSource(
            session: StubStocksHTTPSession(handler: handler),
            configuration: FinnhubConfiguration(
                baseURL: URL(string: "https://example.com/api/v1")!,
                token: "test-token"
            ),
            calendar: Calendar(identifier: .gregorian),
            nowProvider: { resolvedNow }
        )
    }

    func makeAppleStock() -> Stock {
        Stock(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 189.43,
            changePercent: 1.31,
            brand: .apple
        )
    }

    static func endpoint(for request: URLRequest) throws -> String {
        guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        let path = components.path.replacingOccurrences(of: "/api/v1/", with: "")
        let query = (components.queryItems ?? [])
            .filter { $0.name != "token" }
            .sorted { $0.name < $1.name }
            .map { "\($0.name)=\($0.value ?? "")" }
            .joined(separator: "&")

        return query.isEmpty ? path : "\(path)?\(query)"
    }

    static func jsonData(_ string: String) -> Data {
        Data(string.utf8)
    }

    static func makeDate(_ value: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: value) ?? Date(timeIntervalSince1970: 0)
    }
}

private struct StubStocksHTTPSession: StocksHTTPSession {
    let handler: @Sendable (URLRequest) throws -> Data

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let data = try handler(request)
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}
