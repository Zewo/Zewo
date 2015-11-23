Epoch
=====

[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Cocoapods Compatible](https://img.shields.io/badge/Cocoapods-Compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Luminescence)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)

**Epoch** is a Venice based HTTP server for **Swift 2**.

## Features

- [x] No `Foundation` dependency (**Linux ready**)

## Dependencies

**Epoch** is made of:

- [Venice](https://github.com/Zewo/Venice) - CSP and TCP/IP
- [Curvature](https://github.com/Zewo/Curvature) - HTTP request/response
- [Luminescence](https://github.com/Zewo/Luminescence) - HTTP parser
- [Otherside](https://github.com/Zewo/Otherside) - HTTP responder interface

## Related Projects

- [Spell](https://github.com/Zewo/Spell) - HTTP router
- [Fuzz](https://github.com/Zewo/Fuzz) - HTTP middleware framework

## Usage

### Standalone

```swift
import Curvature
import Otherside
import Epoch

struct HTTPServerResponder : HTTPResponderType {
    func respond(request: HTTPRequest) -> HTTPResponse {
    
        // do something based on the HTTPRequest

        return HTTPResponse(status: .OK)
    }
}

let responder = HTTPServerResponder()
let server = HTTPServer(port: 8080, responder: responder)
server.start()
```

### Epoch + Spell

```swift
import Curvature
import Otherside
import Epoch
import Spell

let router = HTTPRouter { router in
	router.post("/users") { request in
	
        // do something based on the HTTPRequest
        
        return HTTPResponse(status: .Created)
    }
    
    router.get("/users/:id") { request in
    
        // do something based on the HTTPRequest
        
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
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'Epoch', '0.3'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate **Epoch** into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Zewo/Epoch" == 0.3
```

### Command Line Application

To use **Epoch** in a command line application:

- Install the [Swift Command Line Application](https://github.com/Zewo/Swift-Command-Line-Application-Template) Xcode template
- Follow [Cocoa Pods](#cocoapods) or [Carthage](#carthage) instructions.

License
-------

**Epoch** is released under the MIT license. See LICENSE for details.
