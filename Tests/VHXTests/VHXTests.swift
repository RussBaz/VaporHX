import LeafKit
@testable import VHX
import XCTest
import XCTVapor

final class VHXTests: XCTestCase {
    // Sanity test
    func testSanity() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let pathToViews = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Views").relativePath

        app.leaf.sources = LeafSources.singleSource(
            NIOLeafFiles(fileio: app.fileio,
                         limits: .default,
                         sandboxDirectory: pathToViews,
                         viewDirectory: pathToViews))

        try configureHtmx(app)
        try configureLocalisation(app, localisations: HXLocalisations())

        app.get("hello") { _ in
            "world"
        }

        app.post("echo") { _ in
            HTTPStatus.ok
        }

        app.get("ok") { req in
            let response = try await HTTPStatus.ok.hx().encodeResponse(for: req)
            response.headers.add(name: "R", value: "\(req.htmx.headers.request)")
            return response
        }

        app.post("redirect", "back") { req in
            try await req.htmx.autoRedirectBack(from: "/ok", htmx: .redirectAndPush, html: .temporary)
        }

        app.get("view", use: staticRoute(template: "test-view"))

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

        try app.testable().test(.POST, "redirect/back/", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .temporaryRedirect)
            XCTAssertEqual(res.headers["HX-Push-Url"].first, "/ok?next=/redirect/back/")
        })

        try app.testable().test(.GET, "view") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>Hello World</p>\n")
        }
    }
}
