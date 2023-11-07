import Vapor

public struct HtmxConfiguration {
    let pageSource: HXLeafSource
}

public extension HtmxConfiguration {
    init() {
        pageSource = hxPageLeafSource(template: nil)
    }

    init(pagePrefix prefix: String) {
        pageSource = hxPageLeafSource(prefix: prefix, template: nil)
    }

    init(pagePrefix prefix: String = "--page", pageTemplate template: @escaping (_ name: String) -> String) {
        pageSource = hxPageLeafSource(prefix: prefix, template: template)
    }
}
