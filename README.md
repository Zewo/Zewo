Epoch
=====

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](http://slack.zewo.io/badge.svg)](http://slack.zewo.io)

**Epoch** is a Venice based HTTP server for **Swift 2.2**.

## Dependencies

**Epoch** is made of:

- [Venice](https://github.com/Zewo/Venice) - CSP and TCP/IP
- [Core](https://github.com/Zewo/Core) - Core
- [HTTP](https://github.com/Zewo/HTTP) - HTTP request/response
- [HTTPParser](https://github.com/Zewo/HTTPParser) - HTTP parser

## Related Projects

- [Router](https://github.com/Zewo/Router) - HTTP router
- [Middleware](https://github.com/Zewo/Middleware) - HTTP middleware framework
- [SQL](https://github.com/Zewo/SQL) - SQL protocols
- [PostgreSQL](https://github.com/Zewo/PostgreSQL) - PostgreSQL client
- [MySQL](https://github.com/Zewo/MySQL) - MySQL client
- [Sideburns](https://github.com/Zewo/Sideburns) - Mustache templates
- [Websocket](https://github.com/Zewo/Websocket) - Websocket server

## Examples

Check what Epoch along other Zewo's modules can do in the [Examples](https://github.com/Zewo/Examples) repo.

## Usage

### Solo

You can use **Epoch** without any extra dependencies if you wish.

```swift
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
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

### Epoch + Router

You'll probably need an HTTP router to make thinks easier. **Epoch** and [Router](https://www.github.com/Zewo/Router) were designed to work with each other seamlessly.

```swift
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import HTTP
import Router
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

**Epoch** depends on the C libs [libvenice](https://github.com/Zewo/libvenice), [http_parser](https://github.com/Zewo/http_parser) and [uri_parser](https://github.com/Zewo/uri_parser).

### OSX 
```bash
$ brew tap zewo/tap
$ brew install libvenice http_parser uri_parser
```

### Linux
```bash
$ echo "deb [trusted=yes] http://apt.zewo.io/deb ./" | sudo tee --append /etc/apt/sources.list
$ sudo apt-get update
$ sudo apt-get install uri-parser http-parser libvenice
```

> You only have to install the C libs once.

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

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**Epoch** is released under the MIT license. See LICENSE for details.
