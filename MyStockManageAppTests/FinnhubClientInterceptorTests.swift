import Foundation
import XCTest
@testable import MyStockManageApp

final class FinnhubClientInterceptorTests: XCTestCase {
    func testFetchQuoteNotifiesInterceptorForRequestAndResponse() async throws {
        let interceptor = SpyStocksHTTPInterceptor()
        let responseData = Self.jsonData(#"{"c":189.43,"dp":1.31}"#)
        let client = FinnhubClient(
            session: StubStocksHTTPSession(
                data: responseData,
                statusCode: 200,
                headers: ["Content-Type": "application/json"]
            ),
            configuration: FinnhubConfiguration(
                baseURL: URL(string: "https://example.com/api/v1")!,
                token: "test-token"
            ),
            interceptor: interceptor
        )

        _ = try await client.fetchQuote(symbol: "AAPL")

        let snapshot = interceptor.snapshot()
        XCTAssertEqual(snapshot.requests.count, 1)
        XCTAssertEqual(
            snapshot.requests.first?.url?.absoluteString,
            "https://example.com/api/v1/quote?symbol=AAPL&token=test-token"
        )
        XCTAssertEqual(snapshot.responses.count, 1)
        XCTAssertEqual(snapshot.responses.first?.statusCode, 200)
        XCTAssertEqual(snapshot.responses.first?.body, responseData)
        XCTAssertEqual(snapshot.errors.count, 0)
    }

    func testFetchQuoteLogsResponseBeforeThrowingInvalidStatusCode() async {
        let interceptor = SpyStocksHTTPInterceptor()
        let client = FinnhubClient(
            session: StubStocksHTTPSession(
                data: Self.jsonData(#"{"error":"unauthorized"}"#),
                statusCode: 401
            ),
            configuration: FinnhubConfiguration(
                baseURL: URL(string: "https://example.com/api/v1")!,
                token: "test-token"
            ),
            interceptor: interceptor
        )

        do {
            _ = try await client.fetchQuote(symbol: "AAPL")
            XCTFail("Expected invalid status code error")
        } catch let error as FinnhubClientError {
            guard case let .invalidStatusCode(statusCode) = error else {
                return XCTFail("Unexpected error: \(error)")
            }

            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let snapshot = interceptor.snapshot()
        XCTAssertEqual(snapshot.requests.count, 1)
        XCTAssertEqual(snapshot.responses.count, 1)
        XCTAssertEqual(snapshot.responses.first?.statusCode, 401)
        XCTAssertEqual(snapshot.errors.count, 0)
    }

    func testLoggingInterceptorRedactsSensitiveRequestValues() {
        let recorder = LogRecorder()
        let interceptor = LoggingStocksHTTPInterceptor(sink: { [recorder] entry in
            recorder.record(entry)
        })
        var request = URLRequest(
            url: URL(string: "https://example.com/api/v1/quote?symbol=AAPL&token=secret-token")!
        )
        request.httpMethod = "GET"
        request.addValue("Bearer secret-value", forHTTPHeaderField: "Authorization")

        interceptor.willSend(request)

        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        guard let response else {
            return XCTFail("Expected HTTPURLResponse")
        }

        interceptor.didReceive(
            data: Self.jsonData(#"{"c":189.43,"dp":1.31}"#),
            response: response,
            for: request
        )

        let entries = recorder.entries
        XCTAssertEqual(entries.count, 2)
        XCTAssertTrue(entries[0].contains("token=REDACTED"))
        XCTAssertFalse(entries[0].contains("secret-token"))
        XCTAssertTrue(entries[0].contains("Authorization: <redacted>"))
        XCTAssertTrue(entries[1].contains("[API Response]"))
        XCTAssertTrue(entries[1].contains("\"c\""))
    }
}

private extension FinnhubClientInterceptorTests {
    static func jsonData(_ string: String) -> Data {
        Data(string.utf8)
    }
}

private final class SpyStocksHTTPInterceptor: StocksHTTPInterceptor, @unchecked Sendable {
    private let lock = NSLock()
    private var requests: [URLRequest] = []
    private var responses: [LoggedResponse] = []
    private var errors: [String] = []

    func willSend(_ request: URLRequest) {
        lock.lock()
        requests.append(request)
        lock.unlock()
    }

    func didReceive(data: Data, response: URLResponse, for _: URLRequest) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

        lock.lock()
        responses.append(LoggedResponse(statusCode: statusCode, body: data))
        lock.unlock()
    }

    func didFail(_ error: any Error, for _: URLRequest) {
        lock.lock()
        errors.append(String(describing: error))
        lock.unlock()
    }

    func snapshot() -> InterceptorSnapshot {
        lock.lock()
        let snapshot = InterceptorSnapshot(
            requests: requests,
            responses: responses,
            errors: errors
        )
        lock.unlock()
        return snapshot
    }
}

private final class LogRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String] = []

    func record(_ entry: String) {
        lock.lock()
        storage.append(entry)
        lock.unlock()
    }

    var entries: [String] {
        lock.lock()
        let snapshot = storage
        lock.unlock()
        return snapshot
    }
}

private struct StubStocksHTTPSession: StocksHTTPSession {
    let data: Data
    let statusCode: Int
    var headers: [String: String] = [:]

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )
        guard let response else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}

private struct LoggedResponse {
    let statusCode: Int
    let body: Data
}

private struct InterceptorSnapshot {
    let requests: [URLRequest]
    let responses: [LoggedResponse]
    let errors: [String]
}
