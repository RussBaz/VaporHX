# VaporHX - Swift Vapor + Htmx + Extensions

**VaporHX** is a collection of Htmx and other extensions that I made when started working with htmx in a personal project (and thus they can be quite opinionated). In any case, please feel free to discuss any changes, as I am open to new and convincing ideas.

NOTE: All the HTMX parts are fully functional and they are actively used by me, even if the documentation is incomplete. I am sorry about this but it writing docs is incredibly tedious.

## Core Idea

The core idea is that you can combine your existing API endpoints with HTMX endpoints with minimal effort. The response will depend on the value of the request `Accept` header and the request method.

All you need to do is to call the `hx(template: String)` method on your `Content` struct and return its value. It will automatically pick the appropriate response, whether it is JSON encoded data, a full HTML page or an HTMX fragment. When HTML (HTMX) is returned, your content is injected into the specified template as a context. It uses the Leaf templating engine by default.

However, you do not have to use the Leaf engine if you do not want to. This package defines `HXTemplateable` protocol with a single render method that returns an html page as a string. For as long as your own templating engine implements it, you can pass its type into the `hx(template:)` method instead.

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

    // Or an even quicker definition of simple 'static' routes
    app.get("static", use: staticRoute(template: "my-static-template"))
}
```

Basic configuration (`configure.swift`):

```swift
import Vapor
import VHX

// Basic config configures Leaf engine but you are not required to use it
// Basic config assumes 'index-base.leaf' template exists and that it contains '#import("body")' tag
// It will generate a dynamic template that wraps the content of the specified template for NON-htmx calls to 'htmx.render'
// It will simply plug the provided template into the 'body' slot of the base template

public func configure(_ app: Application) async throws {
    let config = HtmxConfiguration.basic()
    try configureHtmx(app, configuration: config)
}
```

## Table of Contents

- [What is HTMX?](#what-is-htmx)
- [HTMX](#htmx)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [HX Request Extensions](#hx-request-extensions)
  - [HX Extension Method and HX\<MyType\>](#hx-extension-method-and-hxmytype)
  - [HX Templateable and Custom Templating Engines](#hx-templateable-and-custom-templating-engines)
  - [Request Headers](#request-headers)
  - [Response Headers](#response-headers)
    - [Overview](#overview)
    - [Location](#location)
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
  - [Custom HXTextTag Leaf Tag](#htmx)
- [Other Utilities](#htmx)
  - [String + View](#htmx)
  - [Date + Custom Interval](#htmx)
  - [Request + Base Url](#htmx)
  - [HXAsyncCommand](#htmx)
  - [staticRoute Helper](#htmx)
- [Changelog](#htmx)
- [HTMX Demo](#htmxleaf-demo)

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
.package(url: "https://github.com/RussBaz/VaporHX.git", from: "0.0.23"),
```

- Then add it to your target dependencies

```swift
.product(name: "VHX", package: "VaporHX"),
```

### Configuration

Assuming the standard use of `configure.swift' in all the following examples.

The simplest config usign the Leaf engine (without localisation helpers):

```swift
import Vapor
import VHX

// Basic config configures Leaf engine but you are not required to use it

// Basic config assumes 'index-base.leaf' template exists and that it contains '#import("body")' tag
// It will generate a dynamic template that wraps the content of the specified template for NON-htmx calls to 'htmx.render'
// It will simply plug the provided template into the 'body' slot of the base template

public func configure(_ app: Application) async throws {
  // other configuration
  let config = HtmxConfiguration.basic()
  try configureHtmx(app, configuration: config)
  // more configuration
}
```

Please note that the default wrapper allows dynamically changing the base template name and the slot name. Please refer to the `render` function.

Otherwise, if you want to specify your own htmx page wrapper (plugs the provided template name into a dynamically generated page on NON-HTMX requests):

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

  // Default basic configuration
  static func basic(pagePrefix prefix: String = "--page", baseTemplate: String = "index-base", slotName: String = "body") -> Self
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

In order to manually initialise this struct, please use the following functions:

```swift
func hxPageLeafSource(prefix: String = "--page", template: ((_ name: String) -> String)?) -> HXLeafSource
func hxBasicPageLeafSource(prefix: String = "--page", baseTemplate: String = "index-base", slotName: String = "body") -> HXLeafSource
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
// Setting the 'page' parameter to true will force the server to always return a full page or a page fragment only otherwise
func render(_ name: String, _ context: some Encodable, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response

func render(_ name: String, page: Bool? = nil, headers: HXResponseHeaders? = nil) async throws -> Response

// If you are using a custom templating engine, then you should use this method
func render<T: HXTemplateable>(_ template: T.Type, _ context: T.Context, page: Bool? = nil, headers: HXResponseHeaderAddable? = nil) async throws -> Response
```

Furthermore, if you are using the default template generator, you can manually override the base template name and the slot name. Here is an example how it can be done:

```swift
// Use square brackets at the beginning of the name to override default base template and slot names

routes.get("template") { req in
  // Just square brackets without colons to override base template name only
  try await req.htmx.render("[index-custom]name")
}

routes.get("slot") { req in
  // Use the following format to override a slot name: [template:slot]
  // Using multiple colons will result in an error
  try await req.htmx.render("[index-custom:extra]name")
}
```

To add an HTMX specific header to a response, you can update `response.headers` extension:

```swift
req.htmx.response.headers // HXResponseHeaders
```

Otherwise, you can provide a header to any `render` method. It will override any previously specified headers.

To learn more about the `HXResponseHeaders`, please refere to the [Response Headers](#response-headers) section.

How to redirect quickly with proper HTMX headers?

```swift
// The simplest type of redirect
func redirect(to location: String, htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response

// A helper that looks for a query parameter by the 'key' value and redirects to it
func autoRedirect(key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response

// A helper that looks for a query parameter by the 'key' value
// And then redirects to a 'through location' while preserving the query parameter from the first step during the redirect
// e.g. it can redirect from '/redirect?next=/dashboard/' to '/login?next=/dashboard/'
// by making 'through' equal to '/login'
func autoRedirect(through location: String, key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response

// A helper that redirects to 'from location' while adding the current url as query parameter with a name specified by the 'key'
// It preserves query parameteres from the original url
// e.g from /dashboard/ to /login?next=/dashboard/
// by making 'from' equal to '/login'
func autoRedirectBack(from location: String, key: String = "next", htmx: HXRedirect.Kind = .redirect, html: Redirect = .normal, refresh: Bool = false) async throws -> Response

// -------------------------------------------- //

// HXRedirect.Kind
enum Kind {
  case redirect
  case redirectAndPush
  case redirectAndReplace
}

// What is a 'Redirect' type?
// It is simply the default 'Vapor' type which you use with the 'req.redirect'
```

### HX Extension Method and HX\<MyType\>

The inbuilt `Content` type was extended with an `hx()` method. This is the secret ingredient that adds automatic HTMX support to the standard responses. In addition, some other types have been extended, such as `HTTPStatus` and `Abort`.

Here is how it works:

```swift
// This is a slightly simplified version of this extension method declaration
extension Content where Self: AsyncResponseEncodable & Encodable {
  func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self>

  // For custom templating engines
  func hx<T: HXTemplateable>(template: T.Type, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self> where T.Context == Self
}

// And this is how you would use it
app.get("api") { req in
// Where 'MyApi' is some Content
  MyApi(name: "name").hx(template: "api")
  // The return type of this function call is 'HX<MyApi>'
}
```

One should not normally deal with the `HX` struct directly but in case it is ever needed, here is its definition:

```swift
typealias TemplateRenderer = (_ req: Request, _ context: T, _ page: Bool?, _ headers: HXResponseHeaders?) async throws -> Response

struct HX<T: AsyncResponseEncodable & Encodable> {
  let context: T
  let template: TemplateRenderer?
  let page: Bool?
  let htmxHeaders: HXResponseHeaders?
}
```

### HX Templateable and Custom Templating Engines

If you would like to use your own templating engine, then each renderer should implement the following protocol:

```swift
protocol HXTemplateable {
    associatedtype Context: AsyncResponseEncodable & Encodable

    static func render(req: Request, isPage: Bool, context: Context) -> String
}
```

If this protocol is not enough for your use case, please open an issue and we can discuss it there.

### Request Headers

```swift
// 'HTMX' request header getter on every request
req.htmx.headers

// Request header structure
// For the meaning of value of each header, please refer to the 'HTMX' docs
struct HXRequestHeaders {
  let boosted: Bool
  let currentUrl: String?
  let historyRestoreRequest: Bool
  let prompt: Bool
  let request: Bool
  let target: String?
  let triggerName: String?
  let trigger: String?
}
```

### Response Headers

#### Overview

`HTMX` headers are defined as structs with a simple inbuilt validation. They can be added as individual headers to a `Response` object or as a whole collection by using `HXResponseHeaders` struct. The latter struct can be passed to `htmx` specific functions as an optional parameter, such as `.htmx.render` or `.hx`

```swift
// Cleaned up definition
struct HXResponseHeaders {
  var location: HXLocationHeader?
  var pushUrl: HXPushUrlHeader?
  var redirect: HXRedirectHeader?
  var refresh: HXRefreshHeader?
  var replaceUrl: HXReplaceUrlHeader?
  var reselect: HXReselectHeader?
  var reswap: HXReswapHeader?
  var retarget: HXRetargetHeader?
  var trigger: HXTriggerHeader?
  var triggerAfterSettle: HXTriggerAfterSettleHeader?
  var triggerAfterSwap: HXTriggerAfterSwapHeader?
}

// Example usages
// With 'hx' extension
app.get("api") { req in
  let headers = HXResponseHeaders(retarget: HXRetargetHeader("#content"))
  return MyApi(name: "name").hx(template: "api", headers: headers)
}

// With 'htmx.render' function
app.get("example") { req in
  let headers = HXResponseHeaders(retarget: HXRetargetHeader("#content"))
  return req.htmx.render("example", headers: headers)
}

// With 'add' extension method on 'Response'
// Can be used with the whole container ('HXResponseHeaders') or with individual headers (such as 'HXRetargetHeader')
// Later header values will replace earlier headers
app.get("redirect") { req in
  req.htmx.autoRedirect(through: "/login", html: .temporary).add(headers: HXResponseHeaders())
}
```

#### Location

`HXLocationHeader` is type safe constructor for a `HX-Location` response header. It is the most complicated response header in this library but it is thankfully a rarely used one.

To be continued...

## HTMX+Leaf Demo

For those new to HTMX, this package comes bundled with an HTMX Demo that you can run locally. It consists of a few examples from the [HTMX.org](https://htmx.org/examples/) website.

This is a showcase of some HTMX features built with the Leaf templating engine and VaporHX. It is not a showcase of all the capabilities of this library, but a good introduction to HTMX. It is also not a production ready example.

#### To run the demo using Xcode

- Open this project in Xcode
- Switch the scheme from `VHX` to `Demo` (left hand side of the top url bar)
- Confirm that the correct Run Target is selected (likely 'My Mac')
- Set the custom working directory in the scheme editor to the root folder of this package as shown in the [Vapor docs](https://docs.vapor.codes/getting-started/xcode/). Otherwise, it will display a warning in the console and it will be unable to find leaf templates.
- Press the play / run button
- Then head to `http://localhost:8080`

#### To run the demo using the command line

- execute the following from the VaporHX projects root dir

```bash
swift run Demo
```
