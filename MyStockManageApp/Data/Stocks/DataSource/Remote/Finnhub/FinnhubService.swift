import Foundation

struct FinnhubConfiguration {
    let baseURL: URL
    let token: String?

    init(
        baseURL: URL = Self.defaultBaseURL,
        token: String?
    ) {
        self.baseURL = baseURL
        self.token = token
    }

    static func live(
        infoDictionary: [String: Any] = Bundle.main.infoDictionary ?? [:],
        processEnvironment: [String: String] = ProcessInfo.processInfo.environment
    ) -> FinnhubConfiguration {
        FinnhubConfiguration(
            token: resolvedToken(
                infoDictionary: infoDictionary,
                processEnvironment: processEnvironment
            )
        )
    }

    private static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://finnhub.io/api/v1") else {
            preconditionFailure("Invalid Finnhub base URL")
        }
        return url
    }()

    private static func resolvedToken(
        infoDictionary: [String: Any],
        processEnvironment: [String: String]
    ) -> String? {
        if let plistToken = sanitizedToken(infoDictionary["FINNHUB_API_KEY"] as? String),
           !isUnresolvedBuildSetting(plistToken) {
            return plistToken
        }

        return sanitizedToken(processEnvironment["FINNHUB_API_KEY"])
    }

    private static func sanitizedToken(_ rawValue: String?) -> String? {
        guard let token = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !token.isEmpty else {
            return nil
        }

        return token
    }

    private static func isUnresolvedBuildSetting(_ token: String) -> Bool {
        token.hasPrefix("$(") && token.hasSuffix(")")
    }
}

enum FinnhubServiceError: Error {
    case missingAPIKey
    case invalidURL
    case apiError(String)
}

struct FinnhubService {
    private let httpClient: HTTPClient
    private let configuration: FinnhubConfiguration
    private let calendar: Calendar
    private let nowProvider: () -> Date

    init(
        session: any HTTPClientSession = URLSession.shared,
        configuration: FinnhubConfiguration = .live(),
        calendar: Calendar = .autoupdatingCurrent,
        nowProvider: @escaping () -> Date = Date.init,
        interceptor: (any HTTPInterceptor)? = LoggingHTTPInterceptor()
    ) {
        self.httpClient = HTTPClient(
            session: session,
            interceptor: interceptor
        )
        self.configuration = configuration
        self.calendar = calendar
        self.nowProvider = nowProvider
    }

    func fetchQuote(symbol: String) async throws -> FinnhubQuoteDTO {
        try await request(
            path: "quote",
            queryItems: [URLQueryItem(name: "symbol", value: symbol)],
            responseType: FinnhubQuoteDTO.self
        )
    }

    func fetchCompanyProfile(symbol: String) async throws -> FinnhubProfileDTO {
        try await request(
            path: "stock/profile2",
            queryItems: [URLQueryItem(name: "symbol", value: symbol)],
            responseType: FinnhubProfileDTO.self
        )
    }

    func fetchRecommendations(symbol: String) async throws -> [FinnhubRecommendationDTO] {
        try await request(
            path: "stock/recommendation",
            queryItems: [URLQueryItem(name: "symbol", value: symbol)],
            responseType: [FinnhubRecommendationDTO].self
        )
    }

    func fetchPriceTarget(symbol: String) async throws -> FinnhubPriceTargetDTO {
        try await request(
            path: "stock/price-target",
            queryItems: [URLQueryItem(name: "symbol", value: symbol)],
            responseType: FinnhubPriceTargetDTO.self
        )
    }

    func fetchCompanyNews(symbol: String) async throws -> [FinnhubNewsDTO] {
        let now = nowProvider()
        let startDate = calendar.date(byAdding: .day, value: -14, to: now) ?? now

        return try await request(
            path: "company-news",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "from", value: dateString(from: startDate)),
                URLQueryItem(name: "to", value: dateString(from: now))
            ],
            responseType: [FinnhubNewsDTO].self
        )
    }

    func fetchEarningsHistory(symbol: String) async throws -> [FinnhubEarningsHistoryDTO] {
        try await request(
            path: "stock/earnings",
            queryItems: [URLQueryItem(name: "symbol", value: symbol)],
            responseType: [FinnhubEarningsHistoryDTO].self
        )
    }

    func fetchEarningsCalendar(symbol: String) async throws -> [FinnhubEarningsCalendarDTO] {
        let currentYear = calendar.component(.year, from: nowProvider())

        let envelope = try await request(
            path: "calendar/earnings",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "from", value: "\(currentYear - 1)-01-01"),
                URLQueryItem(name: "to", value: "\(currentYear + 2)-12-31")
            ],
            responseType: FinnhubEarningsCalendarEnvelopeDTO.self
        )

        return envelope.earningsCalendar
    }

    func fetchFinancialReports(
        symbol: String,
        frequency: String
    ) async throws -> [FinnhubFinancialReportDTO] {
        let envelope = try await request(
            path: "stock/financials-reported",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "freq", value: frequency)
            ],
            responseType: FinnhubFinancialReportsEnvelopeDTO.self
        )

        return envelope.data
    }
}

private extension FinnhubService {
    func request<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        responseType _: Response.Type
    ) async throws -> Response {
        guard let token = configuration.token else {
            throw FinnhubServiceError.missingAPIKey
        }

        var components = URLComponents(
            url: configuration.baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems + [
            URLQueryItem(name: "token", value: token)
        ]

        guard let url = components?.url else {
            throw FinnhubServiceError.invalidURL
        }

        let data = try await httpClient.data(for: URLRequest(url: url))

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            if let apiError = try? JSONDecoder().decode(FinnhubErrorDTO.self, from: data) {
                throw FinnhubServiceError.apiError(apiError.error)
            }
            throw error
        }
    }

    func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
