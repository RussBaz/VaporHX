import Vapor

public extension String {
    var asView: View {
        View(data: ByteBuffer(string: self))
    }
}
