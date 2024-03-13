import Vapor

struct InfiniteScrollController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let infiniteScroll = routes.grouped("infinite")

        infiniteScroll.get { req async throws in
            // Extract the `page` param from the URL if one is present, otherwise default to the first page
            let nextPage = extractNextPage(req: req)?.page ?? 1
            // Switch over the preferred response type
            switch req.htmx.prefers {
            case .html:
                // The whole page is being requested
                return try await req.htmx.render("InfiniteScroll/infinite-scroll", ["dto": generateAgents(page: nextPage)])
            case .htmx:
                // Just the fragment containing the next page of Agents is being requested
                try await Task.sleep(for: .seconds(1))
                return try await req.htmx.render("InfiniteScroll/infinite-rows", ["dto": generateAgents(page: nextPage)])
            case .api:
                // The next page of Agents is being requested as JSON
                return try await generateAgents(page: nextPage).encodeResponse(for: req)
            }
        }
    }

    /// Extracts the `page` param from the URL if one is present
    private func extractNextPage(req: Request) -> Payload.NextPage? {
        try? req.query.decode(Payload.NextPage.self)
    }

    /// Just generates the next ten Agents starting at the specified Page
    func generateAgents(page: Int) -> Payload {
        let startIndex = page * 20
        return Payload(
            agents: (0 ... 18).map {
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

    struct Payload: Content {
        struct NextPage: Content {
            let page: Int
        }

        struct Agent: Content {
            let name: String
            let email: String
            var id: String
        }

        let agents: [Agent]
        let lastAgent: Agent
        let nextPage: Int
    }
}
