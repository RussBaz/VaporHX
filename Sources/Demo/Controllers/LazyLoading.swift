import Vapor

struct LazyLoadingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lazy = routes.grouped("lazy")
        
        lazy.get { req async throws in
            return try await req.htmx.render("LazyLoading/lazy-loading")
        }
        
        lazy.get("graph") { req async throws in
            try await Task.sleep(for: .seconds(2))
            return "<img alt='Tokyo Climate' src='/img/tokyo.png'>"
        }
    }
}
