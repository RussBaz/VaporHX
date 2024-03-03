import Vapor

public protocol HXTemplateable {
    associatedtype Context: AsyncResponseEncodable & Encodable

    static func render(req: Request, context: Context, isPage: Bool) -> String
}
