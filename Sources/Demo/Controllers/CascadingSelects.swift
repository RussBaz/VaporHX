import Vapor

struct CascadingSelectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let select = routes.grouped("select", "models")
        
        select.get { req async throws in
            // Extract the Make from the URL or default to Audi if no query param is present
            let make = extractQuery(req: req) ?? .Audi
            // Switch over the prefered request headers
            switch req.htmx.prefers {
            case .html:
                // The entire page is being requested
                return try await req.htmx.render("CascadingSelect/cascading-select", ["dto": DTO(make: make.rawValue, models: make.models)])
            case .htmx:
                // Just a fragment with the related models is being requested
                return try await req.htmx.render("CascadingSelect/cascading-select-options", ["dto": DTO(make: make.rawValue, models: make.models)])
            case .api:
                // The JSON api is being requested
                return try! await DTO(make: make.rawValue, models: make.models).encodeResponse(for: req)
            }
        }
    }
    
    /// Extracts the Make from the url encoded query if one is present
    private func extractQuery(req:Request) -> Make? {
        if let query = try? req.query.decode(Query.self) {
            return Make(rawValue: query.make.lowercased())
        }
        return nil
    }
    
    /// A helper struct for sending data into our Leaf template
    struct DTO:Content {
        let make:String
        let models:[Model]
    }
    
    /// The URL encoded query that our HTMX select view generates
    struct Query:Content {
        let make:String
    }
    
    /// A collection of Makes and Models of cars to choose from
    enum Make:String, Content {
        case Audi   = "audi"
        case Toyota = "toyota"
        case BMW    = "bmw"
        
        var models:[Model] {
            switch self {
            case .Audi: [.init(name: "a1"), .init(name: "a3"), .init(name: "a6")]
            case .Toyota: [.init(name: "landcruiser"), .init(name: "tacoma"), .init(name: "yaris")]
            case .BMW: [.init(name: "325i"), .init(name: "325ix"), .init(name: "x5")]
            }
        }
    }
    
    struct Model:Content {
        let name:String
    }
}
