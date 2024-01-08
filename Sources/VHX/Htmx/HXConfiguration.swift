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

    init(pagePrefix prefix: String = "--page", pageTemplate template: @escaping PageTemplateBuilder) {
        pageSource = hxPageLeafSource(prefix: prefix, template: template)
        errorAttemptCountHeaderName = nil
    }

    static func basic(pagePrefix prefix: String = "--page", baseTemplate: String = "index-base", slotName: String = "body") -> Self {
        let pageSource = hxBasicPageLeafSource(prefix: prefix, baseTemplate: baseTemplate, slotName: slotName)
        let errorAttemptCountHeaderName: String? = nil

        return .init(pageSource: pageSource, errorAttemptCountHeaderName: errorAttemptCountHeaderName)
    }
}
