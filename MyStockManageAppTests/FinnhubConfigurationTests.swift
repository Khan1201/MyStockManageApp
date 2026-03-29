import XCTest
@testable import MyStockManageApp

final class FinnhubConfigurationTests: XCTestCase {
    func testLiveUsesInfoPlistTokenWhenResolved() {
        let configuration = FinnhubConfiguration.live(
            infoDictionary: ["FINNHUB_API_KEY": " plist-token "],
            processEnvironment: ["FINNHUB_API_KEY": "env-token"]
        )

        XCTAssertEqual(configuration.token, "plist-token")
    }

    func testLiveUsesEnvironmentTokenWhenInfoPlistContainsUnresolvedBuildSetting() {
        let configuration = FinnhubConfiguration.live(
            infoDictionary: ["FINNHUB_API_KEY": "$(FINNHUB_API_KEY)"],
            processEnvironment: ["FINNHUB_API_KEY": "env-token"]
        )

        XCTAssertEqual(configuration.token, "env-token")
    }

    func testFetchQuoteThrowsMissingAPIKeyBeforeMakingRequest() async {
        let client = FinnhubClient(
            session: UnexpectedRequestSession(),
            configuration: FinnhubConfiguration(token: nil)
        )

        do {
            _ = try await client.fetchQuote(symbol: "AAPL")
            XCTFail("Expected fetchQuote to throw")
        } catch FinnhubClientError.missingAPIKey {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct UnexpectedRequestSession: StocksHTTPSession {
    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.badServerResponse)
    }
}
