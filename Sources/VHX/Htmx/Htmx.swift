import Vapor

public struct Htmx {
    public enum Preference {
        case htmx, html, api
    }

    let req: Request
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
    func render(_ name: String, _ context: some Encodable, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response {
        let page = page ?? (req.method == .GET && !req.headers.htmx.request)

        let view = if page {
            try await req.view.render("\(req.application.htmx.pageSource.pagePrefix)/\(name)", context).get()
        } else {
            try await req.view.render(name, context).get()
        }

        let response = try await view.encodeResponse(for: req)

        if let headers {
            headers.add(to: response)
        }

        return response
    }

    func render(_ name: String, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response {
        let page = page ?? (req.method == .GET && !req.headers.htmx.request)

        let view = if page {
            try await req.view.render("\(req.application.htmx.pageSource.pagePrefix)/\(name)")
        } else {
            try await req.view.render(name)
        }

        let response = try await view.encodeResponse(for: req)

        if let headers {
            headers.add(to: response)
        }

        return response
    }

    func redirect(to location: String, htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response {
        try await HXRedirect(to: location, htmx: htmx, html: html).encodeResponse(for: req)
    }

    func autoRedirect(key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response {
        try await HXRedirect.auto(from: req, key: key, htmx: htmx, html: html).encodeResponse(for: req)
    }
    
    func autoRedirect(through location: String, key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response {
        try await HXRedirect.auto(from: req, through: location, key: key, htmx: htmx, html: html).encodeResponse(for: req)
    }

    func autoRedirectBack(from location: String, key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response {
        try await HXRedirect.auto(to: location, from: req, key: key, htmx: htmx, html: html).encodeResponse(for: req)
    }
}

public extension Htmx {
    var headers: HXRequestHeaders { req.headers.htmx }
}
