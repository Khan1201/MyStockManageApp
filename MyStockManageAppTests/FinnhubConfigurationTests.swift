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
        let service = FinnhubService(
            session: UnexpectedRequestSession(),
            configuration: FinnhubConfiguration(token: nil)
        )

        do {
            _ = try await service.fetchQuote(symbol: "AAPL")
            XCTFail("Expected fetchQuote to throw")
        } catch FinnhubServiceError.missingAPIKey {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct UnexpectedRequestSession: HTTPClientSession {
    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.badServerResponse)
    }
}
