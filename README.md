# VaporHX - Swift Vapor + Htmx + Extensions

VaporHX is a collection of Htmx and other extensions that I made when started working on htmx in a personal project, and thus they can be opinioted. In any case, please feel free to discuss any changes as I am open to new convincing ideas.

## Core Idea

The core idea is that you can combine your existing api endpoints with HTMX endpoints with minimal effort. The response will depend on the value of the request `Accept` header and the request method.

All you need to do is to call `hx(template: String)` method on your `Content` struct and return its value. It will automatically pick appropriate response, wether it is json encoded data, full html page or an htmx fragment.

```swift
import VHX

// DO NOT forget to call 'configureHtmx' in your 'configure' method before trying this snippet in your project

struct MyApi: Content {
    let name: String
}

func routes(_ app: Application) throws {
    // Combined API and HTMX endpoint
    app.get("api") { req in
        MyApi(name: "name").hx(template: "api")
    }

    // HTMX only endpoint
    // It will automatically select whether to return a full page or only a fragment if the generic page template was configured.
    // Otherwise, it will simply render the 'index.leaf' template
    app.get { req in
        try await req.htmx.render("index")
    }
}
```

Basic configuration (`configure.swift`):

```swift
import Vapor
import VHX

func pageTemplate(_ template: String) -> String {
    """
    #extend("index-base"): #export("body"): #extend("\(template)") #endexport #endextend
    """
}

public func configure(_ app: Application) async throws {
    try configureHtmx(app, pageTemplate: pageTemplate)
}
```

To be continue...
