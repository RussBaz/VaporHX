import Vapor

public struct HXLocationHeader {
    public enum HXLocationType {
        case simple(String)
        case custom(HXCustomLocation)
    }

    public struct HXCustomLocation: Encodable {
        public let path: String
        public let target: String
        public let source: String?
        public let event: String?
        public let handler: String?
        public let swap: HXReswapHeader?
        public let values: [String]?
        public let headers: [String: String]?
    }

    public let location: HXLocationType

    public func serialise() -> String {
        switch location {
        case let .simple(simple):
            return if simple.isEmpty {
                "/"
            } else {
                simple
            }
        case let .custom(custom):
            guard !custom.path.isEmpty else {
                return "/"
            }
            guard let values = try? String(data: JSONEncoder().encode(custom), encoding: .utf8) else {
                return "/"
            }
            return values
        }
    }

    public func add(to resp: Response) {
        let serialised = serialise()

        if !serialised.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Location", value: serialised)
        }
    }
}

public extension HXLocationHeader {
    init(_ path: String) {
        location = .simple(path)
    }

    init(_ path: String, target: String = "body", source: String? = nil, event: String? = nil, handler: String? = nil, swap: HXReswapHeader? = nil, values: [String]? = nil, headers: [String: String]? = nil) {
        location = .custom(.init(path: path, target: target, source: source, event: event, handler: handler, swap: swap, values: values, headers: headers))
    }

    func setTarget(_ newTarget: String) -> Self {
        switch location {
        case let .simple(path):
            .init(path, target: newTarget)
        case let .custom(custom):
            .init(custom.path, target: newTarget, source: custom.source, event: custom.event, handler: custom.handler, swap: custom.swap, values: custom.values, headers: custom.headers)
        }
    }

    func setSource(_ newSource: String?) -> Self {
        switch location {
        case let .simple(path):
            if let newSource {
                .init(path, target: "body", source: newSource)
            } else {
                self
            }

        case let .custom(custom):
            .init(custom.path, target: custom.target, source: newSource, event: custom.event, handler: custom.handler, swap: custom.swap, values: custom.values, headers: custom.headers)
        }
    }

    func setEvent(_ newEvent: String?) -> Self {
        switch location {
        case let .simple(path):
            if let newEvent {
                .init(path, target: "body", event: newEvent)
            } else {
                self
            }
        case let .custom(custom):
            .init(custom.path, target: custom.target, source: custom.source, event: newEvent, handler: custom.handler, swap: custom.swap, values: custom.values, headers: custom.headers)
        }
    }

    func setHandler(_ newHandler: String?) -> Self {
        switch location {
        case let .simple(path):
            if let newHandler {
                .init(path, target: "body", handler: newHandler)
            } else {
                self
            }
        case let .custom(custom):
            .init(custom.path, target: custom.target, source: custom.source, event: custom.event, handler: newHandler, swap: custom.swap, values: custom.values, headers: custom.headers)
        }
    }

    func setSwap(_ newSwap: HXReswapHeader?) -> Self {
        switch location {
        case let .simple(path):
            if let newSwap {
                .init(path, target: "body", swap: newSwap)
            } else {
                self
            }
        case let .custom(custom):
            .init(custom.path, target: custom.target, source: custom.source, event: custom.event, handler: custom.handler, swap: newSwap, values: custom.values, headers: custom.headers)
        }
    }

    func setValues(_ newValues: [String]?) -> Self {
        switch location {
        case let .simple(path):
            if let newValues {
                .init(path, target: "body", values: newValues)
            } else {
                self
            }
        case let .custom(custom):
            .init(custom.path, target: custom.target, source: custom.source, event: custom.event, handler: custom.handler, swap: custom.swap, values: newValues, headers: custom.headers)
        }
    }

    func setHeaders(_ newHeaders: [String: String]?) -> Self {
        switch location {
        case let .simple(path):
            if let newHeaders {
                .init(path, target: "body", headers: newHeaders)
            } else {
                self
            }
        case let .custom(custom):
            .init(custom.path, target: custom.target, source: custom.source, event: custom.event, handler: custom.handler, swap: custom.swap, values: custom.values, headers: newHeaders)
        }
    }

    func setSimple(_ path: String? = nil) -> Self {
        if let path {
            .init(path)
        } else {
            switch location {
            case .simple:
                self
            case let .custom(custom):
                .init(custom.path)
            }
        }
    }
}
