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

> CocoaPods 0.39.0+ is required to build Luminescence.

To integrate Epoch into your Xcode project using CocoaPods, specify it in your `Podfile`:

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

### Manually

If you prefer not to use a dependency manager, you can integrate **Epoch** into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add **Epoch** as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/Zewo/Epoch.git
```

- Open the new `Epoch` folder, and drag the `Epoch.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Epoch.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `Epoch.xcodeproj` folders each with two different versions of the `Epoch.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `Epoch.framework`.

- Select the top `Epoch.framework` for OS X and the bottom one for iOS.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `Epoch` will be listed as either `Epoch iOS` or `Epoch OSX`.

- And that's it!

> The `Epoch.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

###Command Line Application

To use **Epoch** in a command line application:

- Install the [Swift Command Line Application](https://github.com/Zewo/Swift-Command-Line-Application-Template) Xcode template
- Follow [Cocoa Pods](#cocoapods), [Carthage](#carthage) or [Embedded Framework](#embedded-framework) instructions.

License
-------

**Epoch** is released under the MIT license. See LICENSE for details.
