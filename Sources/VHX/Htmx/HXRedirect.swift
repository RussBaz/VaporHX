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
        let response: Response

        if request.htmx.prefers == .htmx {
            response = try await HTTPStatus.noContent.encodeResponse(for: request)
                .add(headers: HXLocationHeader(location))

            switch htmxKind {
            case .redirect:
                if reloadAfterSwap {
                    response.add(headers: HXRefreshHeader())
                }
            case .redirectAndPush:
                if reloadAfterSwap {
                    response.add(headers: HXRedirectHeader(location))
                } else {
                    response.add(headers: HXPushUrlHeader(location))
                }
            case .redirectAndReplace:
                if reloadAfterSwap {
                    response
                        .add(headers: HXReplaceUrlHeader(location))
                        .add(headers: HXRefreshHeader())
                } else {
                    response.add(headers: HXReplaceUrlHeader(location))
                }
            }
        } else {
            response = request.redirect(to: location, redirectType: htmlKind)
        }

        return response
    }
}

public extension HXRedirect {
    static func auto(from req: Request, through location: String? = nil, key: String = "next", htmx: Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) -> Self {
        let next = HXRedirect.next(from: req, key: key)

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

    static func next(from req: Request, key: String = "next") -> String {
        switch req.query[key] ?? "/" {
        case let n where n.starts(with: "/"): n
        case let n: "/\(n)"
        }
    }
}
