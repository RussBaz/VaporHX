import Vapor

struct CascadingSelectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let select = routes.grouped("select", "models")
        
        select.get { req async throws in
            if let query = try? req.query.decode(Query.self) {
                var models:[Model] = []
                if let make = Make(rawValue: query.make.lowercased()) {
                    models = make.models
                }
                return try await req.htmx.render("CascadingSelect/cascading-select-options", ["models": models])
            } else {
                return try await req.htmx.render("CascadingSelect/cascading-select", ["models": Make.Audi.models])
            }
        }
    }
    
    struct Query:Content {
        let make:String
    }
    
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
