import Vapor

public struct Htmx {
    public enum Preference {
        case htmx, html, api
    }

    let req: Request

    public let response: HXResponseConfiguration
}

public extension Htmx {
    var prefered: Bool {
        switch prefers {
        case .htmx: true
        default: false
        }
    }

    var prefers: Preference {
        // Preferences:
        // GET method with expected content json -> standard api response
        // GET method with expected content html without HX-Request header -> standard text/html response
        // GET method with expected content html with HX-Request header -> HTMX response (text/html)
        // GET method with no content prefrences without HX-Request header -> standard text/html response
        // GET method with no content prefrences with HX-Request header -> HTMX response (text/html)

        // All other methods with expected content json -> standard api response
        // All other methods with expected content html without HX-Request header -> standard text/html response
        // All other methods with expected content html with HX-Request header -> HTMX response (text/html)
        // All other methods with no content prefrences without HX-Request header -> standard api response
        // All other methods with no content prefrences with HX-Request header -> HTMX response (text/html)

        let preference = req.headers.accept.comparePreference(for: .json, to: .html)

        return switch preference {
        case .orderedSame:
            if req.method == .GET {
                if req.headers["HX-Request"].isEmpty {
                    .html
                } else {
                    .htmx
                }
            } else {
                if req.headers["HX-Request"].isEmpty {
                    .api
                } else {
                    .htmx
                }
            }
        case .orderedAscending:
            if req.headers["HX-Request"].isEmpty {
                .html
            } else {
                .htmx
            }
        case .orderedDescending:
            .api
        }
    }
}

public extension Htmx {
    func render(_ name: String, _ context: some Encodable, page: Bool? = nil, headers: HXResponseHeaderAddable? = nil) async throws -> Response {
        let page = page ?? (req.method == .GET && !req.headers.htmx.request)

        let templateName: String = if page {
            "\(req.application.htmx.pageSource.pagePrefix)/\(name)"
        } else {
            if name.starts(with: "["), let i = name.firstIndex(of: "]") {
                String(name[name.index(after: i) ..< name.endIndex])
            } else {
                name
            }
        }

        let view = try await req.view.render(templateName, context).get()
        let response = try await view.encodeResponse(for: req)

        req.htmx.response.headers.add(to: response)

        if let headers {
            headers.add(to: response)
        }

        return response
    }

    func render(_ name: String, page: Bool? = nil, headers: HXResponseHeaderAddable? = nil) async throws -> Response {
        let page = page ?? (req.method == .GET && !req.headers.htmx.request)

        let templateName: String = if page {
            "\(req.application.htmx.pageSource.pagePrefix)/\(name)"
        } else {
            if name.starts(with: "["), let i = name.firstIndex(of: "]") {
                String(name[name.index(after: i) ..< name.endIndex])
            } else {
                name
            }
        }

        let view = try await req.view.render(templateName)

        let response = try await view.encodeResponse(for: req)

        req.htmx.response.headers.add(to: response)

        if let headers {
            headers.add(to: response)
        }

        return response
    }

    func render<T: HXTemplateable>(_ template: T.Type, _ context: T.Context, page: Bool? = nil, headers: HXResponseHeaderAddable? = nil) async throws -> Response {
        let page = page ?? (req.method == .GET && !req.headers.htmx.request)

        let view = template.render(req: req, isPage: page, context: context).asView
        let response = try await view.encodeResponse(for: req)

        req.htmx.response.headers.add(to: response)

        if let headers {
            headers.add(to: response)
        }

        return response
    }

    func render<T: HXTemplateable>(_ template: T.Type, page: Bool? = nil, headers: HXResponseHeaderAddable? = nil) async throws -> Response where T.Context == EmptyContext {
        try await render(template, EmptyContext(), page: page, headers: headers)
    }

    func redirect(to location: String, htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response {
        try await HXRedirect(to: location, htmx: htmx, html: html, refresh: refresh).encodeResponse(for: req)
    }

    func autoRedirect(key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response {
        try await HXRedirect.auto(from: req, key: key, htmx: htmx, html: html, refresh: refresh).encodeResponse(for: req)
    }

    func autoRedirect(through location: String, key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response {
        try await HXRedirect.auto(from: req, through: location, key: key, htmx: htmx, html: html, refresh: refresh).encodeResponse(for: req)
    }

    func autoRedirectBack(from location: String, key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response {
        try await HXRedirect.auto(to: location, from: req, key: key, htmx: htmx, html: html, refresh: refresh).encodeResponse(for: req)
    }
}

public extension Htmx {
    var headers: HXRequestHeaders { req.headers.htmx }
}
