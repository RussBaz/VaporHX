import Vapor

struct InfiniteScrollController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let infiniteScroll  = routes.grouped("infinite")
        
        infiniteScroll.get { req async throws in
            var nextPage = 1
            if let pageParam = try? req.query.decode(Payload.NextPage.self) {
                nextPage = pageParam.page
            }
            
            if nextPage == 1 {
                return try await req.htmx.render("InfiniteScroll/infinite-scroll", ["in": generateAgents(page: nextPage)])
            } else {
                try await Task.sleep(for: .seconds(1))
                return try await req.htmx.render("InfiniteScroll/infinite-rows", ["in": generateAgents(page: nextPage)])
            }
        }
    }
    
    func generateAgents(page: Int) -> Payload {
        let startIndex = page * 20
        return Payload(
            agents: (0...18).map {
                .init(
                    name: "Agent Smith",
                    email: "void\(startIndex + $0)@null.org",
                    id: String(UUID().uuidString.prefix(8))
                )
            },
            lastAgent: .init(
                name: "Agent Smith",
                email: "void\(startIndex + 19)@null.org",
                id: String(UUID().uuidString.prefix(8))
            ),
            nextPage: page + 1
        )
    }

    struct Payload:Content {
        struct NextPage:Content {
            let page:Int
        }
        
        struct User:Content {
            let name:String
            let email:String
            var id:String
        }
        
        let agents:[User]
        let lastAgent:User
        let nextPage: Int
    }
}
