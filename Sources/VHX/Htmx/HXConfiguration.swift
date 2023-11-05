import Vapor

public struct HtmxConfiguration {
    let pageSource: HXLeafSource
}

public extension HtmxConfiguration {
    init() {
        pageSource = hxPageLeafSource(template: nil)
    }

    init(template: @escaping (_ name: String) -> String) {
        pageSource = hxPageLeafSource(template: template)
    }
}
