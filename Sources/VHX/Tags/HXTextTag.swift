import Leaf

public enum TextTagError: Error {
    case invalidFormatParameter
    case wrongNumberOfParameters
}

public struct HXTextTag: LeafTag {
    public func render(_ ctx: LeafContext) throws -> LeafData {
        guard ctx.parameters.count == 1 else {
            throw TextTagError.wrongNumberOfParameters
        }
        guard let text = ctx.parameters[0].string else {
            throw TextTagError.invalidFormatParameter
        }

        let localised = if let req = ctx.request {
            req.language.localise(text: text)
        } else {
            text
        }

        return LeafData.string(localised)
    }
}
