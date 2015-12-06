Epoch
=====

[![Swift 2.2](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](https://zewo-slackin.herokuapp.com)

**Epoch** is a Venice based HTTP server for **Swift 2.2**.

## Dependencies

**Epoch** is made of:

- [Venice](https://github.com/Zewo/Venice) - CSP and TCP/IP
- [URI](https://github.com/Zewo/URI) - URI
- [HTTP](https://github.com/Zewo/HTTP) - HTTP request/response
- [HTTPParser](https://github.com/Zewo/HTTPParser) - HTTP parser

## Related Projects

- [HTTPRouter](https://github.com/Zewo/HTTPRouter) - HTTP router
- [HTTPMiddleware](https://github.com/Zewo/HTTPMiddleware) - HTTP middleware framework

## Usage

### Solo

You can use **Epoch** without any extra dependencies if you wish.

```swift
import HTTP
import Epoch

struct HTTPServerResponder: HTTPResponderType {
    func respond(request: HTTPRequest) -> HTTPResponse {
        // do something based on the HTTPRequest
        return HTTPResponse(status: .OK)
    }
}

let responder = HTTPServerResponder()
let server = HTTPServer(port: 8080, responder: responder)
server.start()
```

### Epoch + HTTPRouter

You'll probably need an HTTP router to make thinks easier. **Epoch** and [HTTPRouter](https://www.github.com/Zewo/HTTPRouter) were designed to work with each other seamlessly.

```swift
import HTTP
import HTTPRouter
import Epoch

let router = HTTPRouter { router in
    router.post("/users") { request in
        // do something based on the HTTPRequest
        return HTTPResponse(status: .Created)
    }

    router.get("/users/:id") { request in
        let id = request.parameters["id"]
        // do something based on the HTTPRequest and id
        return HTTPResponse(status: .OK)
    } 
}

let server = HTTPServer(port: 8080, responder: router)
server.start()
```

## Installation

- Install [`uri_parser`](https://github.com/Zewo/uri_parser)

```bash
$ git clone https://github.com/Zewo/uri_parser.git
$ cd uri_parser
$ make
$ dpkg -i uri_parser.deb
```

- Install [`http_parser`](https://github.com/Zewo/http_parser)

```bash
$ git clone https://github.com/Zewo/http_parser.git
$ cd http_parser
$ make
$ dpkg -i http_parser.deb
```

- Install [`libvenice`](https://github.com/Zewo/libvenice)

```bash
$ git clone https://github.com/Zewo/libvenice.git
$ cd libvenice
$ make
$ dpkg -i libvenice.deb
```

- Add `Epoch` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/Zewo/Epoch.git", majorVersion: 0, minor: 1)
	]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](https://zewo-slackin.herokuapp.com)

Join us on [Slack](https://zewo-slackin.herokuapp.com).

License
-------

**Epoch** is released under the MIT license. See LICENSE for details.
