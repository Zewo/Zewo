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

## Examples

Check what Epoch along other Zewo's modules can do in the [Examples](https://github.com/Zewo/Examples) repo.

## Usage

### Solo

You can use **Epoch** without any extra dependencies if you wish.

```swift
import Glibc
import HTTP
import Epoch
import CHTTPParser
import CLibvenice

struct ServerResponder: ResponderType {
    func respond(request: Request) -> Response {
        // do something based on the Request
        return Response(status: .OK)
    }
}

let responder = ServerResponder()
let server = Server(port: 8080, responder: responder)
server.start()
```

### Epoch + HTTPRouter

You'll probably need an HTTP router to make thinks easier. **Epoch** and [HTTPRouter](https://www.github.com/Zewo/HTTPRouter) were designed to work with each other seamlessly.

```swift
import Glibc
import HTTP
import HTTPRouter
import Epoch
import CHTTPParser
import CLibvenice

let router = Router { router in
    router.post("/users") { request in
        // do something based on the Request
        return Response(status: .Created)
    }

    router.get("/users/:id") { request in
        let id = request.parameters["id"]
        // do something based on the Request and id
        return Response(status: .OK)
    } 
}

let server = Server(port: 8080, responder: router)
server.start()
```

## Installation

**Epoch** depends on the C libs [libvenice](https://github.com/Zewo/libvenice), [http_parser](https://github.com/Zewo/http_parser) and [uri_parser](https://github.com/Zewo/uri_parser). Install them through:

### Homebrew 
```bash
$ brew tap zewo/tap
$ brew install libvenice
$ brew install http_parser
$ brew install uri_parser
```

### Ubuntu/Debian
```bash
$ git clone https://github.com/Zewo/libvenice.git && cd libvenice
$ make
$ make package
$ dpkg -i libvenice.deb
$ git clone https://github.com/Zewo/http_parser.git && cd http_parser
$ make
$ make package
$ dpkg -i http_parser.deb
$ git clone https://github.com/Zewo/uri_parser.git && cd uri_parser
$ make
$ make package
$ dpkg -i uri_parser.deb
```

### Source
```bash
$ git clone https://github.com/Zewo/libvenice.git && cd libvenice
$ make
$ (sudo) make install
$ git clone https://github.com/Zewo/http_parser.git && cd http_parser
$ make
$ (sudo) make install
$ git clone https://github.com/Zewo/uri_parser.git && cd uri_parser
$ make
$ (sudo) make install
```

Then add `Epoch` to your `Package.swift`

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
