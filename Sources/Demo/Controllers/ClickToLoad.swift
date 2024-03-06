import Vapor

struct ClickToLoadController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let clickToLoad  = routes.grouped("contacts")
        
        clickToLoad.get { req async throws in
            var nextPage = 1
            if let pageParam = try? req.query.decode(Payload.NextPage.self) {
                nextPage = pageParam.page
            }
            
            if nextPage == 1 {
                return try await req.htmx.render("ClickToLoad/click-to-load", ["in": generateAgents(page: nextPage)])
            } else {
                return try await req.htmx.render("ClickToLoad/click-to-load-rows", ["in": generateAgents(page: nextPage)])
            }
        }
    }
    
    func generateAgents(page: Int) -> Payload {
        let startIndex = page * 10
        return Payload(
            agents: (0...9).map { 
                .init(
                    name: "Agent Smith",
                    email: "void\(startIndex + $0)@null.org",
                    id: String(UUID().uuidString.prefix(8))
                )
            },
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
        let nextPage: Int
    }
}
