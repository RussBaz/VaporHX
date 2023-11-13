import Vapor

public struct HtmxConfiguration {
    public var pageSource: HXLeafSource
    public var errorAttemptCountHeaderName: String?

    public init(pageSource: HXLeafSource, errorAttemptCountHeaderName: String? = nil) {
        self.pageSource = pageSource
        self.errorAttemptCountHeaderName = errorAttemptCountHeaderName
    }
}

public extension HtmxConfiguration {
    init() {
        pageSource = hxPageLeafSource(template: nil)
        errorAttemptCountHeaderName = nil
    }

    init(pagePrefix prefix: String) {
        pageSource = hxPageLeafSource(prefix: prefix, template: nil)
        errorAttemptCountHeaderName = nil
    }

    init(pagePrefix prefix: String = "--page", pageTemplate template: @escaping (_ name: String) -> String) {
        pageSource = hxPageLeafSource(prefix: prefix, template: template)
        errorAttemptCountHeaderName = nil
    }
}
