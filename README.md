# VaporHX - Swift Vapor + Htmx + Extensions

**VaporHX** is a collection of Htmx and other extensions that I made when started working with htmx in a personal project (and thus they can be quite opinionated). In any case, please feel free to discuss any changes, as I am open to new and convincing ideas.

## Core Idea

The core idea is that you can combine your existing API endpoints with HTMX endpoints with minimal effort. The response will depend on the value of the request `Accept` header and the request method.

All you need to do is to call the `hx(template: String)` method on your `Content` struct and return its value. It will automatically pick the appropriate response, whether it is JSON encoded data, a full HTML page or an HTMX fragment. When HTML (HTMX) is returned, your content is injected into the specified template as a context.

```swift
import VHX

// Do NOT forget to call 'configureHtmx' in your 'configure' method before trying this snippet in your project

// Also, do NOT create a folder called '--page' in your template root without changing the default VHX settings
// as it is used as a prefix for dynamically generated wrapper page templates
// and the custom template provider is the last one to be checked after the default ones are run

// Furthermore, this snippet assumes the default leaf naming conventions as they can be manually overriden

struct MyApi: Content {
    let name: String
}

func routes(_ app: Application) throws {
    // Combined API and HTMX endpoint
    // 'api.leaf' template must exist
    app.get("api") { req in
        MyApi(name: "name").hx(template: "api")
    }

    // HTMX only endpoint
    // 'index.leaf' template must exist
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

// Assumes 'index-base.leaf' template exists and that it contains '#import("body")' tag
// Generates a dynamic template that wraps the content of the specified template
// This is the template that will be returned when a standard html GET request is made to an htmx endpoint.
func pageTemplate(_ template: String) -> String {
    """
    #extend("index-base"): #export("body"): #extend("\(template)") #endexport #endextend
    """
}

public func configure(_ app: Application) async throws {
    try configureHtmx(app, pageTemplate: pageTemplate)
}
```

SPM installation:

- Add the package to your package dependencies

```swift
.package(url: "https://github.com/RussBaz/VHX.git", from: "0.0.7"),
```

- Then add it to your target dependencies

```swift
.product(name: "VHX", package: "VHX"),
```

## Table of Contents

- [What is HTMX?](#what-is-htmx)
- [HTMX](#htmx)
  - [Configuration](#htmx)
  - [Htmx Request Extensions](#htmx)
  - [HX\<MyType\>](#htmx)
  - [Hx Extension Method](#htmx)
  - [Request Headers](#htmx)
  - [Response Headers](#htmx)
    - [Overview](#htmx)
    - [Location](#htmx)
    - [Push Url](#htmx)
    - [Redirect](#htmx)
    - [Refresh](#htmx)
    - [Replace Url](#htmx)
    - [Reselect](#htmx)
    - [Reswap](#htmx)
    - [Retarget](#htmx)
    - [Trigger, Trigger After Settle and Trigger After Swap](#htmx)
  - [HXError, Abort and HXErrorMiddleware](#htmx)
  - [HXRedirect](#htmx)
- [Simple Localisation](#htmx)
  - [Configuration](#htmx)
  - [HXLocalisable Protocol and HXLocalisation](#htmx)
  - [HXRequestLocalisation](#htmx)
  - [Custom HXTextTag leaf tag](#htmx)
- [Other Utilities](#htmx)
  - [Date + Custom Interval](#htmx)
  - [Request + Base Url](#htmx)
- [Changelog](#htmx)

## What is HTMX?

Here is my hot take: Make your backend code the single source of truth for your project, and drop most of your front end bloat in favour of updating your HTML in-place and seamlessly. Without reloading the page and with only your server side HTML templates. Learn more at [htmx.org](https://htmx.org/).

## HTMX

To be continued...
