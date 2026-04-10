import Foundation
import OSLog

protocol HTTPInterceptor: Sendable {
    func willSend(_ request: URLRequest)
    func didReceive(data: Data, response: URLResponse, for request: URLRequest)
    func didFail(_ error: any Error, for request: URLRequest)
}

struct LoggingHTTPInterceptor: HTTPInterceptor {
    private static let defaultSubsystem = Bundle.main.bundleIdentifier ?? "MyStockManageApp"

    private let logger: Logger
    private let sink: (@Sendable (String) -> Void)?

    init(
        logger: Logger = Logger(subsystem: Self.defaultSubsystem, category: "API"),
        sink: (@Sendable (String) -> Void)? = nil
    ) {
        self.logger = logger
        self.sink = sink
    }

    func willSend(_ request: URLRequest) {
        logDebug(formatRequest(request))
    }

    func didReceive(data: Data, response: URLResponse, for request: URLRequest) {
        logDebug(formatResponse(data: data, response: response, request: request))
    }

    func didFail(_ error: any Error, for request: URLRequest) {
        logError(formatError(error, request: request))
    }
}

private extension LoggingHTTPInterceptor {
    var maxLoggedBodyLength: Int { 2_000 }

    func logDebug(_ message: String) {
        if let sink {
            sink(message)
            return
        }

        logger.debug("\(message, privacy: .public)")
    }

    func logError(_ message: String) {
        if let sink {
            sink(message)
            return
        }

        logger.error("\(message, privacy: .public)")
    }

    func formatRequest(_ request: URLRequest) -> String {
        let method = request.httpMethod ?? "GET"
        let url = sanitizedURLString(from: request.url) ?? "<missing-url>"
        let headers = formattedHeaders(from: request.allHTTPHeaderFields ?? [:])
        let body = formattedRequestBody(from: request.httpBody)

        return """
        [API Request]
        \(method) \(url)
        Headers: \(headers)
        Body: \(body)
        """
    }

    func formatResponse(data: Data, response: URLResponse, request: URLRequest) -> String {
        let url = sanitizedURLString(from: response.url ?? request.url) ?? "<missing-url>"
        let body = formattedResponseBody(from: data)

        if let httpResponse = response as? HTTPURLResponse {
            let headers = formattedHeaders(from: httpResponse.allHeaderFields)
            return """
            [API Response]
            \(httpResponse.statusCode) \(url)
            Headers: \(headers)
            Body: \(body)
            """
        }

        return """
        [API Response]
        Non-HTTP \(url)
        Body: \(body)
        """
    }

    func formatError(_ error: any Error, request: URLRequest) -> String {
        let method = request.httpMethod ?? "GET"
        let url = sanitizedURLString(from: request.url) ?? "<missing-url>"

        return """
        [API Error]
        \(method) \(url)
        Error: \(String(describing: error))
        """
    }

    func sanitizedURLString(from url: URL?) -> String? {
        guard let url else {
            return nil
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }

        components.queryItems = components.queryItems?.map { item in
            if item.name.caseInsensitiveCompare("token") == .orderedSame {
                return URLQueryItem(name: item.name, value: "REDACTED")
            }

            return item
        }

        return components.url?.absoluteString ?? url.absoluteString
    }

    func formattedHeaders(from headers: [String: String]) -> String {
        guard !headers.isEmpty else {
            return "none"
        }

        return headers
            .map { key, value in
                "\(key): \(redactedHeaderValue(for: key, value: value))"
            }
            .sorted()
            .joined(separator: ", ")
    }

    func formattedHeaders(from headers: [AnyHashable: Any]) -> String {
        let mappedHeaders = headers.reduce(into: [String: String]()) { partialResult, entry in
            guard let key = entry.key as? String else {
                return
            }

            partialResult[key] = String(describing: entry.value)
        }

        return formattedHeaders(from: mappedHeaders)
    }

    func redactedHeaderValue(for key: String, value: String) -> String {
        let normalizedKey = key.lowercased()
        let sensitiveKeys = ["authorization", "x-api-key", "api-key"]

        if sensitiveKeys.contains(normalizedKey) || normalizedKey.contains("token") {
            return "<redacted>"
        }

        return value
    }

    func formattedRequestBody(from data: Data?) -> String {
        guard let data else {
            return "none"
        }

        return formattedBody(from: data)
    }

    func formattedResponseBody(from data: Data) -> String {
        guard !data.isEmpty else {
            return "empty"
        }

        return formattedBody(from: data)
    }

    func formattedBody(from data: Data) -> String {
        guard !data.isEmpty else {
            return "empty"
        }

        if let formattedJSON = formattedJSONBody(from: data) {
            return truncate(formattedJSON)
        }

        if let stringValue = String(data: data, encoding: .utf8) {
            return truncate(stringValue)
        }

        return "<\(data.count) bytes>"
    }

    func formattedJSONBody(from data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              JSONSerialization.isValidJSONObject(jsonObject),
              let prettyData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
              ),
              let stringValue = String(data: prettyData, encoding: .utf8) else {
            return nil
        }

        return stringValue
    }

    func truncate(_ value: String) -> String {
        guard value.count > maxLoggedBodyLength else {
            return value
        }

        let endIndex = value.index(value.startIndex, offsetBy: maxLoggedBodyLength)
        return "\(value[..<endIndex])..."
    }
}
