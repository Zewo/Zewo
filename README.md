Epoch
=====

[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Cocoapods Compatible](https://img.shields.io/badge/Cocoapods-Compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Epoch)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)

**Epoch** is a Venice based HTTP server for **Swift 2**.

## Features

- [x] No `Foundation` dependency (**Linux ready**)

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

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build Epoch.

To integrate **Epoch** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/Zewo/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'Epoch', '0.4'
```
> Don't forget  `source 'https://github.com/Zewo/Specs.git'`. This is very important. It should always come before the official CocoaPods repo.

Then, run the following command:

```bash
$ pod install
```

### Command Line Application

To use **Epoch** in a command line application:

- Install the [Swift Command Line Application](https://github.com/Zewo/Swift-Command-Line-Application-Template) Xcode template
- Follow [Cocoa Pods](#cocoapods) instructions.

License
-------

**Epoch** is released under the MIT license. See LICENSE for details.
