@testable import VHX
import XCTest
import XCTVapor

final class VHXTests: XCTestCase {
    // Sanity test
    func testSanity() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        app.views.use(.leaf)
        try configureHtmx(app)
        try configureLocalisation(app, localisations: HXLocalisations())

        app.get("hello") { _ in
            "world"
        }

        app.get("ok") { req in
            let response = try await HTTPStatus.ok.hx().encodeResponse(for: req)
            response.headers.add(name: "R", value: "\(req.htmx.headers.request)")
            return response
        }

        try app.testable().test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "world")
        }

        try app.testable().test(.GET, "ok", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.json.serialize())
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers["R"].first, "false")
        })

        try app.testable().test(.GET, "ok", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertEqual(res.headers["R"].first, "false")
        })

        try app.testable().test(.GET, "ok", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertEqual(res.headers["R"].first, "true")
        })
    }
}
