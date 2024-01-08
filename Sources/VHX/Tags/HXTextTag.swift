import Leaf

public enum TextTagError: Error {
    case invalidFormatParameter
    case wrongNumberOfParameters
}

public struct HXTextTag: LeafTag {
    public func render(_ ctx: LeafContext) throws -> LeafData {
        guard ctx.parameters.count == 1 || ctx.parameters.count == 2 else {
            throw TextTagError.wrongNumberOfParameters
        }
        guard let text = ctx.parameters[0].string else {
            throw TextTagError.invalidFormatParameter
        }

        let code: String?

        if ctx.parameters.count == 2 {
            guard let c = ctx.parameters[1].string else {
                throw TextTagError.invalidFormatParameter
            }
            code = c
        } else {
            code = nil
        }

        let localised = if let req = ctx.request {
            req.language.localise(text: text, for: code)
        } else {
            text
        }

        return LeafData.string(localised)
    }

    public init() {}
}
