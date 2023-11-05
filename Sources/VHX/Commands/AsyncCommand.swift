import Vapor

// Code is taken from the following tutorial:
// https://theswiftdev.com/running-and-testing-async-vapor-commands/

public protocol CustomAsyncCommand: Command {
    func command(
        using context: CommandContext,
        signature: Signature
    ) async throws
}

public extension CustomAsyncCommand {
    func run(
        using context: CommandContext,
        signature: Signature
    ) throws {
        let promise = context
            .application
            .eventLoopGroup
            .next()
            .makePromise(of: Void.self)

        promise.completeWithTask {
            try await command(
                using: context,
                signature: signature
            )
        }
        try promise.futureResult.wait()
    }
}
