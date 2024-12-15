import LeafKit
@testable import VHX
import XCTest
import XCTVapor

final class VHXTests: XCTestCase {
    struct LocationResponseHeaderTest2: Content {
        let path: String
        let target: String
    }

    struct Superhero: Content, Equatable {
        let name: String
        let superpower: String
    }

    struct SomeTemplateable: HXTemplateable {
        static func render(req: Request, isPage: Bool, context: Superhero) -> String {
            "Hello, \(context.name). Your superpower is \(context.superpower). [Page: \(isPage), type: \(req.htmx.prefers)]"
        }
    }

    struct AnotherTemplateable: HXTemplateable {
        static func render(req _: Request, isPage: Bool, context _: EmptyContext) -> String {
            "Empty. Page: \(isPage)."
        }
    }

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

        app.post("empty", use: staticRoute(template: AnotherTemplateable.self))

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

        app.post("redirect", "form", "success") { _ in
            HXRedirect(to: "/hello", htmx: .redirectAndReplace)
        }

        app.get("view", use: staticRoute(template: "test-view"))

        app.get("view", "override", "template") { req in
            try await req.htmx.render("[index-custom]world")
        }

        app.get("view", "override", "slot") { req in
            try await req.htmx.render("[index-custom:extra]world")
        }

        app.get("templateable") { _ in
            let hero = Superhero(name: "Mr Freeman", superpower: "science")
            return hero.hx(template: SomeTemplateable.self)
        }

        app.get("header") { req async throws in
            req.htmx.response.headers.retarget = HXRetargetHeader("#content")
            req.htmx.response.headers.reselect = HXReselectHeader("body")
            return try await req.htmx.render("world", headers: [HXRefreshHeader(), HXReselectHeader("form")])
        }

        app.get("header", "location", "test") { req in
            req.htmx.response.headers.location = HXLocationHeader("/test")
            return try await req.htmx.render("world")
        }

        app.get("header", "location", "test2") { req in
            req.htmx.response.headers.location = HXLocationHeader("/test2", target: "#testdiv")
            return try await req.htmx.render("world")
        }

        try app.testable().test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "world")
        }

        try app.testable().test(.GET, "ok") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.json.serialize())
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers["R"].first, "false")
        }

        try app.testable().test(.GET, "ok") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertEqual(res.headers["R"].first, "false")
        }

        try app.testable().test(.GET, "ok") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertEqual(res.headers["R"].first, "true")
        }

        try app.testable().test(.POST, "redirect/back/") { res in
            XCTAssertEqual(res.status, .temporaryRedirect)
            XCTAssertEqual(res.headers[.location].first, "/ok?next=/redirect/back/")
            XCTAssertNil(res.headers["HX-Push-Url"].first)
        }

        try app.testable().test(.POST, "redirect/back/") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertNil(res.headers[.location].first)
            XCTAssertEqual(res.headers["HX-Push-Url"].first, "/ok?next=/redirect/back/")
        }

        try app.testable().test(.POST, "redirect/form/success") { res in
            XCTAssertEqual(res.status, .seeOther)
            XCTAssertEqual(res.headers[.location].first, "/hello")
            XCTAssertNil(res.headers["HX-Replace-Url"].first)
        }

        try app.testable().test(.POST, "redirect/form/success") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            XCTAssertNil(res.headers[.location].first)
            XCTAssertEqual(res.headers["HX-Replace-Url"].first, "/hello")
        }

        try app.testable().test(.GET, "view") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Hello</p> <p>Hello World</p>\n </div>\n")
        }

        try app.testable().test(.GET, "view/override/template") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Welcome</p> <p>World!</p>\n </div>\n\n")
        }

        try app.testable().test(.GET, "view/override/template") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
        }

        try app.testable().test(.GET, "view/override/slot") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<div><p>Welcome</p></div>\n <p>World!</p>\n \n")
        }

        try app.testable().test(.GET, "view/override/slot") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
        }

        try app.testable().test(.GET, "templateable") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, Mr Freeman. Your superpower is science. [Page: true, type: html]")
        }

        try app.testable().test(.GET, "templateable") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, Mr Freeman. Your superpower is science. [Page: false, type: htmx]")
        }

        try app.testable().test(.GET, "templateable") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.json.serialize())
        } afterResponse: { res in
            let hero = try res.content.decode(Superhero.self)
            let expectedHero = Superhero(name: "Mr Freeman", superpower: "science")
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(hero, expectedHero)
        }

        try app.testable().test(.POST, "empty") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Empty. Page: false.")
        }

        try app.testable().test(.GET, "header") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
            XCTAssertTrue(res.headers.contains(name: "HX-Refresh"))
            XCTAssertTrue(res.headers.contains(name: "HX-Retarget"))
            XCTAssertTrue(res.headers.contains(name: "HX-Reselect"))
            XCTAssertEqual(res.headers["HX-Refresh"].count, 1)
            XCTAssertEqual(res.headers["HX-Retarget"].count, 1)
            XCTAssertEqual(res.headers["HX-Reselect"].count, 1)
            XCTAssertEqual(res.headers["HX-Refresh"].first, "true")
            XCTAssertEqual(res.headers["HX-Retarget"].first, "#content")
            XCTAssertEqual(res.headers["HX-Reselect"].first, "form")
        }

        try app.testable().test(.GET, "header/location/test") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
            XCTAssertTrue(res.headers.contains(name: "HX-Location"))
            XCTAssertEqual(res.headers["HX-Location"].count, 1)
            XCTAssertEqual(res.headers["HX-Location"].first, "/test")
        }

        try app.testable().test(.GET, "header/location/test2") { req in
            req.headers.replaceOrAdd(name: .accept, value: HTTPMediaType.html.serialize())
            req.headers.replaceOrAdd(name: "HX-Request", value: "true")
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "<p>World!</p>\n")
            XCTAssertTrue(res.headers.contains(name: "HX-Location"))
            XCTAssertEqual(res.headers["HX-Location"].count, 1)
            if let value = res.headers["HX-Location"].first?.data(using: .utf8) {
                let decoder = JSONDecoder()
                if let location = try? decoder.decode(LocationResponseHeaderTest2.self, from: value) {
                    XCTAssertEqual(location.path, "/test2")
                    XCTAssertEqual(location.target, "#testdiv")
                } else {
                    XCTFail("HX-Location value could not be decoded")
                }
            } else {
                XCTFail("HX-Location value was nil")
            }
        }
    }
}
