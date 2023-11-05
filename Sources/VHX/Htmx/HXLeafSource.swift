import LeafKit
import Vapor

public protocol HXLeafSource: LeafSource {
    var pagePrefix: String { get }
}

public struct HXBasicLeafSource: HXLeafSource {
    public let pagePrefix: String
    public let pageTemplate: (_ name: String) -> String

    public enum HtmxPageLeafSourceError: Error {
        case illegalFormat
    }

    public func file(template: String, escape _: Bool, on eventLoop: EventLoop) throws -> EventLoopFuture<ByteBuffer> {
        guard template.starts(with: "\(pagePrefix)/") else {
            throw HtmxPageLeafSourceError.illegalFormat
        }

        let remainder = template.dropFirst(7)

        guard remainder.distance(from: remainder.startIndex, to: template.endIndex) > 0 else {
            throw HtmxPageLeafSourceError.illegalFormat
        }

        let result = pageTemplate(String(remainder))

        let buffer = ByteBuffer(string: result)

        return eventLoop.makeSucceededFuture(buffer)
    }
}

public func hxPageLeafSource(prefix: String = "--page", template: ((_ name: String) -> String)?) -> HXLeafSource {
    if let template {
        return HXBasicLeafSource(pagePrefix: prefix, pageTemplate: template)
    } else {
        func template(_ name: String) -> String {
            """
            #extend("\(name)")
            """
        }
        return HXBasicLeafSource(pagePrefix: prefix, pageTemplate: template)
    }
}
