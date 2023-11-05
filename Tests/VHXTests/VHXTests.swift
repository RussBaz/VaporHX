@testable import VHX
import XCTest
import XCTVapor

final class VHXTests: XCTestCase {
    // Sanity test
    func testSanity() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.get("hello") { _ in
            "world"
        }

        try app.testable().test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "world")
        }
    }
}
