import Vapor

struct ActiveSearchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let activeSearch = routes.grouped("activeSearch")

        activeSearch.get { req async throws in
            try await req.htmx.render("ActiveSearch/active-search")
        }

        activeSearch.post { req async throws in
            var ranks: [(Int, ActiveSearch.User)] = []

            if let query = try? req.content.decode(ActiveSearch.Query.self), !query.search.isEmpty {
                req.logger.info("Query: `\(query.search)`")
                // Search the mockUsers for similarities
                ranks.append(contentsOf:
                    ActiveSearch.default.users.map { ("\($0.firstName.prefix(query.search.count))".levenshteinDistanceScore(to: query.search), $0) }.sorted(by: { $0.0 < $1.0 }).prefix(10)
                )
                ranks.append(contentsOf:
                    ActiveSearch.default.users.map { ("\($0.lastName.prefix(query.search.count))".levenshteinDistanceScore(to: query.search), $0) }.sorted(by: { $0.0 < $1.0 }).prefix(10)
                )
                ranks.append(contentsOf:
                    ActiveSearch.default.users.map { ("\($0.email.prefix(query.search.count))".levenshteinDistanceScore(to: query.search), $0) }.sorted(by: { $0.0 < $1.0 }).prefix(10)
                )
                ranks.sort { r1, r2 in
                    r1.0 < r2.0
                }
                ranks = Array(ranks.uniqued(on: { $0.1 }).prefix(10))

            } else {
                req.logger.warning("No Query")
            }

            return try await req.htmx.render("ActiveSearch/active-search-rows", ["users": ranks.map(\.1)])
        }
    }
}

/// - Warning: Don't do this in production!
struct ActiveSearch: Content {
    struct Query: Content {
        let search: String
    }

    struct User: Content, Hashable {
        let firstName: String
        let lastName: String
        let email: String

        var toString: String {
            "\(firstName) \(lastName) \(email)"
        }
    }

    var users: [User]

    static var `default`: ActiveSearch = .init(users: [
        .init(firstName: "Venus", lastName: "Grimes", email: "lectus.rutrum@Duisa.edu"),
        .init(firstName: "Fletcher", lastName: "Owen", email: "metus@Aenean.org"),
        .init(firstName: "William", lastName: "Hale", email: "eu.dolor@risusodio.edu"),
        .init(firstName: "TaShya", lastName: "Cash", email: "tincidunt.orci.quis@nuncnullavulputate.co.uk"),
        .init(firstName: "Kevyn", lastName: "Hoover", email: "tristique.pellentesque.tellus@Cumsociis.co.uk"),
        .init(firstName: "Jakeem", lastName: "Walker", email: "Morbi.vehicula.Pellentesque@faucibusorci.org"),
        .init(firstName: "Malcolm", lastName: "Trujillo", email: "sagittis@velit.edu"),
        .init(firstName: "Wynne", lastName: "Rice", email: "augue.id@felisorciadipiscing.edu"),
        .init(firstName: "Evangeline", lastName: "Klein", email: "adipiscing.lobortis@sem.org"),
        .init(firstName: "Jennifer", lastName: "Russell", email: "sapien.Aenean.massa@risus.com"),
        .init(firstName: "Rama", lastName: "Freeman", email: "Proin@quamPellentesquehabitant.net"),
        .init(firstName: "Jena", lastName: "Mathis", email: "non.cursus.non@Phaselluselit.com"),
        .init(firstName: "Alexandra", lastName: "Maynard", email: "porta.elit.a@anequeNullam.ca"),
        .init(firstName: "Tallulah", lastName: "Haley", email: "ligula@id.net"),
        .init(firstName: "Timon", lastName: "Small", email: "velit.Quisque.varius@gravidaPraesent.org"),
        .init(firstName: "Randall", lastName: "Pena", email: "facilisis@Donecconsectetuer.edu"),
        .init(firstName: "Conan", lastName: "Vaughan", email: "luctus.sit@Classaptenttaciti.edu"),
        .init(firstName: "Dora", lastName: "Allen", email: "est.arcu.ac@Vestibulumante.co.uk"),
        .init(firstName: "Aiko", lastName: "Little", email: "quam.dignissim@convallisest.net"),
        .init(firstName: "Jessamine", lastName: "Bauer", email: "taciti.sociosqu@nibhvulputatemauris.co.uk"),
        .init(firstName: "Gillian", lastName: "Livingston", email: "justo@atiaculisquis.com"),
        .init(firstName: "Laith", lastName: "Nicholson", email: "elit.pellentesque.a@diam.org"),
        .init(firstName: "Paloma", lastName: "Alston", email: "cursus@metus.org"),
        .init(firstName: "Freya", lastName: "Dunn", email: "Vestibulum.accumsan@metus.co.uk"),
        .init(firstName: "Griffin", lastName: "Rice", email: "justo@tortordictumeu.net"),
        .init(firstName: "Catherine", lastName: "West", email: "malesuada.augue@elementum.com"),
        .init(firstName: "Jena", lastName: "Chambers", email: "erat.Etiam.vestibulum@quamelementumat.net"),
        .init(firstName: "Neil", lastName: "Rodriguez", email: "enim@facilisis.com"),
        .init(firstName: "Freya", lastName: "Charles", email: "metus@nec.net"),
        .init(firstName: "Anastasia", lastName: "Strong", email: "sit@vitae.edu"),
        .init(firstName: "Bell", lastName: "Simon", email: "mollis.nec.cursus@disparturientmontes.ca"),
        .init(firstName: "Minerva", lastName: "Allison", email: "Donec@nequeIn.edu"),
        .init(firstName: "Yoko", lastName: "Dawson", email: "neque.sed@semper.net"),
        .init(firstName: "Nadine", lastName: "Justice", email: "netus@et.edu"),
        .init(firstName: "Hoyt", lastName: "Rosa", email: "Nullam.ut.nisi@Aliquam.co.uk"),
        .init(firstName: "Shafira", lastName: "Noel", email: "tincidunt.nunc@non.edu"),
        .init(firstName: "Jin", lastName: "Nunez", email: "porttitor.tellus.non@venenatisamagna.net"),
        .init(firstName: "Barbara", lastName: "Gay", email: "est.congue.a@elit.com"),
        .init(firstName: "Riley", lastName: "Hammond", email: "tempor.diam@sodalesnisi.net"),
        .init(firstName: "Molly", lastName: "Fulton", email: "semper@Naminterdumenim.net"),
        .init(firstName: "Dexter", lastName: "Owen", email: "non.ante@odiosagittissemper.ca"),
        .init(firstName: "Kuame", lastName: "Merritt", email: "ornare.placerat.orci@nisinibh.ca"),
        .init(firstName: "Maggie", lastName: "Delgado", email: "Nam.ligula.elit@Cum.org"),
        .init(firstName: "Hanae", lastName: "Washington", email: "nec.euismod@adipiscingelit.org"),
        .init(firstName: "Jonah", lastName: "Cherry", email: "ridiculus.mus.Proin@quispede.edu"),
        .init(firstName: "Cheyenne", lastName: "Munoz", email: "at@molestiesodalesMauris.edu"),
        .init(firstName: "India", lastName: "Mack", email: "sem.mollis@Inmi.co.uk"),
        .init(firstName: "Lael", lastName: "Mcneil", email: "porttitor@risusDonecegestas.com"),
        .init(firstName: "Jillian", lastName: "Mckay", email: "vulputate.eu.odio@amagnaLorem.co.uk"),
        .init(firstName: "Shaine", lastName: "Wright", email: "malesuada@pharetraQuisqueac.org"),
        .init(firstName: "Keane", lastName: "Richmond", email: "nostra.per.inceptos@euismodurna.org"),
        .init(firstName: "Samuel", lastName: "Davis", email: "felis@euenim.com"),
        .init(firstName: "Zelenia", lastName: "Sheppard", email: "Quisque.nonummy@antelectusconvallis.org"),
        .init(firstName: "Giacomo", lastName: "Cole", email: "aliquet.libero@urnaUttincidunt.ca"),
        .init(firstName: "Mason", lastName: "Hinton", email: "est@Nunc.co.uk"),
        .init(firstName: "Katelyn", lastName: "Koch", email: "velit.Aliquam@Suspendisse.edu"),
        .init(firstName: "Olga", lastName: "Spencer", email: "faucibus@Praesenteudui.net"),
        .init(firstName: "Erasmus", lastName: "Strong", email: "dignissim.lacus@euarcu.net"),
        .init(firstName: "Regan", lastName: "Cline", email: "vitae.erat.vel@lacusEtiambibendum.co.uk"),
        .init(firstName: "Stone", lastName: "Holt", email: "eget.mollis.lectus@Aeneanegestas.ca"),
        .init(firstName: "Deanna", lastName: "Branch", email: "turpis@estMauris.net"),
        .init(firstName: "Rana", lastName: "Green", email: "metus@conguea.edu"),
        .init(firstName: "Caryn", lastName: "Henson", email: "Donec.sollicitudin.adipiscing@sed.net"),
        .init(firstName: "Clarke", lastName: "Stein", email: "nec@mollis.co.uk"),
        .init(firstName: "Kelsie", lastName: "Porter", email: "Cum@gravidaAliquam.com"),
        .init(firstName: "Cooper", lastName: "Pugh", email: "Quisque.ornare.tortor@dictum.co.uk"),
        .init(firstName: "Paul", lastName: "Spencer", email: "ac@InfaucibusMorbi.com"),
        .init(firstName: "Cassady", lastName: "Farrell", email: "Suspendisse.non@venenatisa.net"),
        .init(firstName: "Sydnee", lastName: "Velazquez", email: "mollis@loremfringillaornare.com"),
        .init(firstName: "Felix", lastName: "Boyle", email: "id.libero.Donec@aauctor.org"),
        .init(firstName: "Ryder", lastName: "House", email: "molestie@natoquepenatibus.org"),
        .init(firstName: "Hadley", lastName: "Holcomb", email: "penatibus@nisi.ca"),
        .init(firstName: "Marsden", lastName: "Nunez", email: "Nulla.eget.metus@facilisisvitaeorci.org"),
        .init(firstName: "Alana", lastName: "Powell", email: "non.lobortis.quis@interdumfeugiatSed.net"),
        .init(firstName: "Dennis", lastName: "Wyatt", email: "Morbi.non@nibhQuisquenonummy.ca"),
        .init(firstName: "Karleigh", lastName: "Walton", email: "nascetur.ridiculus@quamdignissimpharetra.com"),
        .init(firstName: "Brielle", lastName: "Donovan", email: "placerat@at.edu"),
        .init(firstName: "Donna", lastName: "Dickerson", email: "lacus.pede.sagittis@lacusvestibulum.com"),
        .init(firstName: "Eagan", lastName: "Pate", email: "est.Nunc@cursusNunc.ca"),
        .init(firstName: "Carlos", lastName: "Ramsey", email: "est.ac.facilisis@duinec.co.uk"),
        .init(firstName: "Regan", lastName: "Murphy", email: "lectus.Cum@aptent.com"),
        .init(firstName: "Claudia", lastName: "Spence", email: "Nunc.lectus.pede@aceleifend.co.uk"),
        .init(firstName: "Genevieve", lastName: "Parker", email: "ultrices@inaliquetlobortis.net"),
        .init(firstName: "Marshall", lastName: "Allison", email: "erat.semper.rutrum@odio.org"),
        .init(firstName: "Reuben", lastName: "Davis", email: "Donec@auctorodio.edu"),
        .init(firstName: "Ralph", lastName: "Doyle", email: "pede.Suspendisse.dui@Curabitur.org"),
        .init(firstName: "Constance", lastName: "Gilliam", email: "mollis@Nulla.edu"),
        .init(firstName: "Serina", lastName: "Jacobson", email: "dictum.augue@ipsum.net"),
        .init(firstName: "Charity", lastName: "Byrd", email: "convallis.ante.lectus@scelerisquemollisPhasellus.co.uk"),
        .init(firstName: "Hyatt", lastName: "Bird", email: "enim.Nunc.ut@nonmagnaNam.com"),
        .init(firstName: "Brent", lastName: "Dunn", email: "ac.sem@nuncid.com"),
        .init(firstName: "Casey", lastName: "Bonner", email: "id@ornareelitelit.edu"),
        .init(firstName: "Hakeem", lastName: "Gill", email: "dis@nonummyipsumnon.org"),
        .init(firstName: "Stewart", lastName: "Meadows", email: "Nunc.pulvinar.arcu@convallisdolorQuisque.net"),
        .init(firstName: "Nomlanga", lastName: "Wooten", email: "inceptos@turpisegestas.ca"),
        .init(firstName: "Sebastian", lastName: "Watts", email: "Sed.diam.lorem@lorem.co.uk"),
        .init(firstName: "Chelsea", lastName: "Larsen", email: "ligula@Nam.net"),
        .init(firstName: "Cameron", lastName: "Humphrey", email: "placerat@id.org"),
        .init(firstName: "Juliet", lastName: "Bush", email: "consectetuer.euismod@vitaeeratVivamus.co.uk"),
        .init(firstName: "Caryn", lastName: "Hooper", email: "eu.enim.Etiam@ridiculus.org"),
    ])
}

extension String {
    func levenshteinDistanceScore(to string: String) -> Int {
        Tools.levenshtein(aStr: self, bStr: string)
    }
}

//
//  Tools.swift
//  Levenshtein — swift
//
//  Created by Virumax on 6/20/18.
//  Copyright © Virendra Ravalji. All rights reserved.
//

/**
 * Levenshtein edit distance calculator
 * Usage: levenstein <string> <string>
 *
 * Inspired by https://gist.github.com/kyro38/50102a47937e9896e4f4
 * Comment by RussBaz: The link to the gist is broken. Remove or replace?
 */

private class Tools {
    private class func min(numbers: Int...) -> Int {
        numbers.reduce(numbers[0]) { $0 < $1 ? $0 : $1 }
    }

    class Array2D {
        var cols: Int, rows: Int
        var matrix: [Int]

        init(cols: Int, rows: Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(repeating: 0, count: cols * rows)
        }

        subscript(col: Int, row: Int) -> Int {
            get {
                matrix[cols * row + col]
            }
            set {
                matrix[cols * row + col] = newValue
            }
        }

        func colCount() -> Int {
            cols
        }

        func rowCount() -> Int {
            rows
        }
    }

    class func levenshtein(aStr: String, bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)

        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)

        for i in 1 ... a.count {
            dist[i, 0] = i
        }

        for j in 1 ... b.count {
            dist[0, j] = j
        }

        for i in 1 ... a.count {
            for j in 1 ... b.count {
                if a[i - 1] == b[j - 1] {
                    dist[i, j] = dist[i - 1, j - 1] // noop
                } else {
                    dist[i, j] = min(
                        numbers: dist[i - 1, j] + 1, // deletion
                        dist[i, j - 1] + 1, // insertion
                        dist[i - 1, j - 1] + 1 // substitution
                    )
                }
            }
        }

        return dist[a.count, b.count]
    }
}
