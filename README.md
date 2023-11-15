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
        // The return type of this function call is 'HX<MyApi>'
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
// The default implementation simply returns '#extend("\(name)")'
func pageTemplate(_ template: String) -> String {
    """
    #extend("index-base"): #export("body"): #extend("\(template)") #endexport #endextend
    """
}

public func configure(_ app: Application) async throws {
    try configureHtmx(app, pageTemplate: pageTemplate)
}
```

## Table of Contents

- [What is HTMX?](#what-is-htmx)
- [HTMX](#htmx)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [HX Request Extensions](#hx-request-extensions)
  - [HX Extension Method and HX\<MyType\>](#htmx)
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
  - [HXAsyncCommand](#htmx)
- [Changelog](#htmx)

## What is HTMX?

Here is my hot take: Make your backend code the single source of truth for your project, and drop most of your front end bloat in favour of updating your HTML in-place and seamlessly. Without reloading the page and with only your server side HTML templates. Learn more at [htmx.org](https://htmx.org/).

And here is the official intro:

> - Why should only `<a>` and `<form>` be able to make HTTP requests?
> - Why should only `click` & `submit` events trigger them?
> - Why should only `GET` & `POST` methods be available?
> - Why should you only be able to replace the **_entire_** screen?
>
> By removing these **_arbitrary constraints_**, htmx completes HTML as a **_hypertext_**.

Lastly, here is a quick introduction to HTMX by `Fireship`: [htmx in 100 seconds](https://www.youtube.com/watch?v=r-GSGH2RxJs).

## HTMX

### Installation

SPM installation:

- Add the package to your package dependencies

```swift
.package(url: "https://github.com/RussBaz/VaporHX.git", from: "0.0.9"),
```

- Then add it to your target dependencies

```swift
.product(name: "VHX", package: "VaporHX"),
```

### Configuration

Assuming the standard use of `configure.swift`:

```swift
// The most straightforward configuration
import Vapor
import VHX

// Defining the page dynamic template generator separately
// Check the 'HXBasicLeafSource' later in this section for further details
func pageTemplate(_ template: String) -> String {
  """
  #extend("index-base"): #export("body"): #extend("\(template)") #endexport #endextend
  """
}

public func configure(_ app: Application) async throws {
  // Other configuration
  // HTMX configuration also enables leaf templating language
  try configureHtmx(app, pageTemplate: pageTemplate)
  // Later configuration and routes registration
}
```

Here are all the signatures:

```swift
func configureHtmx(_ app: Application, pageTemplate template: ((_ name: String) -> String)? = nil) throws
// or
func configureHtmx(_ app: Application, configuration: HtmxConfiguration) throws

// -------------------------------------------- //

// This struct stores globally available (through the Application) htmx configuration
struct HtmxConfiguration {
  var pageSource: HXLeafSource
  // A header name that will be copied back from the request when HXError is thrown
  // The header type must be UInt, otherwise 0 is returned
  // Should be used by the client when retrying
  var errorAttemptCountHeaderName: String?

  // Possible ways to init the configuration structure
  init()
  init(pagePrefix prefix: String)
  init(pagePrefix prefix: String = "--page", pageTemplate template: @escaping (_ name: String) -> String)
  init(pageSource: HXLeafSource, errorAttemptCountHeaderName: String? = nil)
}
```

`HXLeafSource` is used to generate a dynamic template that is used for wrapping HTMX fragments with the rest of the page content when it is accessed through a normal browser request.

It satisfies the following protocol:

```swift
protocol HXLeafSource: LeafSource {
  var pagePrefix: String { get }
}
```

Where `LeafSource` is a special `Leaf` protocol designed for customising how leaf templates are discovered.

Then **VaporHX** implements its implementation of this specialised protocol.

```swift
struct HXBasicLeafSource: HXLeafSource {
  let pagePrefix: String
  // This is our custom template generator
  let pageTemplate: (_ name: String) -> String
}
```

In order to manually initialise this struct, please use the following function:

```swift
func hxPageLeafSource(prefix: String = "--page", template: ((_ name: String) -> String)?) -> HXLeafSource
```

In our case the default `pagePrefix` value is `--page`. Therefore, everytime you ask `leaf` for a template prefixed with `--page/` (please do not miss `/` after the prefix, it is always required), the default `HXBasicLeafSource` will return a template generated by the `pageTemplate` closure. Everything after the prefix with `/` will be passed into the page template generator and the result of this function should be a valid `leaf` template as a string.

The value passed to the `pageTemplate` method must not be empty. If it is, then `HXBasicLeafSource` will return a 'not found' error.

Lastly, this `LeafSource` implementation is registered as a last leaf source, and this means that the default search path is fully preserved.

### HX Request Extensions

How to check if the incoming request is an HTMX request?

```swift
// Check this extensions property on the 'Request' object
req.htmx.prefered // Bool
// And if you want more more accuracy ...
req.htmx.prefers // Preference

// -------------------------------------------- //

// HTMX case implies an HTMX fragment
// HTML case implies standard browser request
// API case implies json api request
enum Preference {
  case htmx, html, api
}
```

How to automatically decide if you need to render an HTMX fragment or a full page?

```swift
// Try this method on the 'req.htmx' extension
// This method tries to mimic the 'req.view.render' api
// but it also can accept optional HXResponseHeaders
func render(_ name: String, _ context: some Encodable, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response

func render(_ name: String, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response
```

To learn more about the `HXResponseHeaders`, please refere to the Response Headers section.

How to redirect quickly with proper HTMX headers?

```swift
// The simplest type of redirect
func redirect(to location: String, htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response

// A helper that looks for a query parameter by the 'key' value and redirects to it
func autoRedirect(key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response

// A helper that looks for a query parameter by the 'key' value
// And then redirects to a 'through location' while preserving the query parameter from the first step during the redirect
// e.g. it can redirect from '/redirect?next=/dashboard' to '/login?next=/dashboard'
// by making 'through' equal to '/login'
func autoRedirect(through location: String, key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response

// A helper that redirects to 'from location' while adding the current url as query parameter with a name specified by the 'key'
// It preserves query parameteres from the original url
// e.g from /dashboard to /login?next=/dashboard
// by making 'from' equal to '/login'
func autoRedirectBack(from location: String, key: String = "next", htmx: HXRedirect.Kind = .pushFragment, html: Redirect = .normal) async throws -> Response

// -------------------------------------------- //

// HXRedirect.Kind
enum Kind {
  case replacePage
  case pushPage
  case replaceFragment
  case pushFragment
}

// What is a 'Redirect' type?
// It is simply the default 'Vapor' type which you use with the 'req.redirect'
```

To be continued...
