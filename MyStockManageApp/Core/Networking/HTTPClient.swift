import Foundation

protocol HTTPClientSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClientSession {}

enum HTTPClientError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
}

struct HTTPClient {
    private let session: any HTTPClientSession
    private let interceptor: (any HTTPInterceptor)?

    init(
        session: any HTTPClientSession = URLSession.shared,
        interceptor: (any HTTPInterceptor)? = LoggingHTTPInterceptor()
    ) {
        self.session = session
        self.interceptor = interceptor
    }

    func data(for request: URLRequest) async throws -> Data {
        interceptor?.willSend(request)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            interceptor?.didFail(error, for: request)
            throw error
        }

        interceptor?.didReceive(data: data, response: response, for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPClientError.invalidStatusCode(httpResponse.statusCode)
        }

        return data
    }
}
