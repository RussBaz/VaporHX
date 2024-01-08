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

        let config = HtmxConfiguration.basic()
        try configureHtmx(app, configuration: config)
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

        app.get("view", "override", "template") { req in
            try await req.htmx.render("[index-custom]world")
        }

        app.get("view", "override", "slot") { req in
            try await req.htmx.render("[index-custom:extra]world")
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

        try app.testable().test(.POST, "redirect/back/", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .temporaryRedirect)
            XCTAssertEqual(res.headers["HX-Push-Url"].first, "/ok?next=/redirect/back/")
        })

        try app.testable().test(.GET, "view") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Hello</p> <p>Hello World</p>\n </div>\n")
        }

        try app.testable().test(.GET, "view/override/template") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Welcome</p> <p>World!</p>\n </div>\n\n")
        }

        try app.testable().test(.GET, "view/override/template", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
        })

        try app.testable().test(.GET, "view/override/slot") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Welcome</p></div>\n <p>World!</p>\n \n")
        }

        try app.testable().test(.GET, "view/override/slot", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
        })
    }
}
