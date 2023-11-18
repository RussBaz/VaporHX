import Vapor

public struct HXRedirect {
    public enum Kind {
        case redirect
        case redirectAndPush
        case redirectAndReplace
    }

    public let location: String
    public let htmlKind: Redirect
    public let htmxKind: Kind
    public let reloadAfterSwap: Bool

    public init(to location: String, htmx: Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) {
        if location.isEmpty {
            self.location = "/"
        } else {
            self.location = location
        }
        htmlKind = html
        htmxKind = htmx
        reloadAfterSwap = refresh
    }
}

extension HXRedirect: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        switch htmxKind {
        case .redirect:
            if reloadAfterSwap {
                request.redirect(to: location, redirectType: htmlKind)
                    .add(headers: HXRefreshHeader())
            } else {
                request.redirect(to: location, redirectType: htmlKind)
            }
        case .redirectAndPush:
            if reloadAfterSwap {
                request.redirect(to: location, redirectType: htmlKind)
                    .add(headers: HXRedirectHeader(location))
            } else {
                request.redirect(to: location, redirectType: htmlKind)
                    .add(headers: HXPushUrlHeader(location))
            }
        case .redirectAndReplace:
            if reloadAfterSwap {
                request.redirect(to: location, redirectType: htmlKind)
                    .add(headers: HXReplaceUrlHeader(location))
                    .add(headers: HXRefreshHeader())
            } else {
                request.redirect(to: location, redirectType: htmlKind)
                    .add(headers: HXReplaceUrlHeader(location))
            }
        }
    }
}

public extension HXRedirect {
    static func auto(from req: Request, through location: String? = nil, key: String = "next", htmx: Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) -> Self {
        let next = switch req.query[key] ?? "/" {
        case let n where n.starts(with: "/"): n
        case let n: "/\(n)"
        }

        let nextUrl = if let location, !location.isEmpty {
            "\(location)?\(key)=\(next)"
        } else {
            next
        }

        return .init(to: nextUrl, htmx: htmx, html: html, refresh: refresh)
    }

    static func auto(to location: String, from req: Request, key: String = "next", htmx: Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) -> Self {
        let query = if let q = req.url.query { "?\(q)" } else { "" }
        let next = "\(location)?\(key)=\(req.url.path)\(query)"

        return .init(to: next, htmx: htmx, html: html, refresh: refresh)
    }
}
