# Mapper

[![Swift][swift-badge]][swift-url]
[![Zewo][zewo-badge]][zewo-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

**Mapper** is a tiny and simple library which allows you to convert Zewo's `StructuredData` to strongly typed objects. Deeply inspired by Lyft's Mapper.

## Usage

#### Simplest example:

``` swift
import Mapper

struct User: Mappable {
    let id: Int
    let username: String
    let city: String?
    
    // Mappable requirement
    init(mapper: Mapper) throws {
        id = try mapper.map(from: "id")
        username = try mapper.map(from: "username")
        city = mapper.map(optionalFrom: "city")
    }
}

let content: StructuredData = [
    "id": 1654,
    "username": "fireringer",
    "city": "Houston"
]
let user = User.makeWith(structuredData: content) // User?
```

#### Mapping arrays

**Be careful!** If you use `map(from:)` instead of `map(arrayFrom:)`, mapping will fail.

```swift
struct Album: Mappable {
    let songs: [String]
    init(mapper: Mapper) throws {
        songs = try mapper.map(arrayFrom: "songs")
    }
}

struct Album: Mappable {
    let songs: [String]?
    init(mapper: Mapper) throws {
        songs = try mapper.map(optionalArrayFrom: "songs")
    }
}
```

#### Mapping enums
You can use **Mapper** for mapping enums with raw values. Right now you can use only `String`, `Int` and `Double` as raw value.

```swift
enum GuitarType: String {
    case acoustic
    case electric
}

struct Guitar: Mappable {
    let vendor: String
    let type: GuitarType
    
    init(mapper: Mapper) throws {
        vendor = try mapper.map(from: "vendor")
        type = try mapper.map(from: "type")
    }
}
```

#### Nested `Mappable` objects

```swift
struct League: Mappable {
    let name: String
    init(mapper: Mapper) throws {
        name = try mapper.map(from: "name")
    }
}

struct Club: Mappable {
    let name: String
    let league: League
    init(mapper: Mapper) throws {
        name = try mapper.map(from: "name")
        league = try mapper.map(from: "league")
    }
}
```

#### Using `StructuredDataInitializable`
`Mappable` is great for complex entities, but for the simplest one you can use `StructuredDataInitializable` protocol. `StructuredDataInitializable` objects can be initializaed from `StructuredData` itself, not from its `Mapper`. For example, **Mapper** uses `StructuredDataInitializable` to allow seamless `Int` conversion:

```swift
extension Int: StructuredDataInitializable {
    public init(structuredData value: StructuredData) throws {
        switch value {
        case .numberValue(let number):
            self.init(number)
        default:
            throw InitializableError.cantBindToNeededType
        }
    }
}
```

Now you can map `Int` using `from(_:)` just like anything else:

```swift
struct Generation: Mappable {
    let number: Int
    init(mapper: Mapper) throws {
        number = try mapper.map(from: "number")
    }
}
```

Conversion of `Int` is available in **Mapper** out of the box, and you can extend any other type to conform to `StructuredDataInitializable` yourself, for example, `NSDate`:

```swift
import Foundation
import Mapper

extension StructuredDataInitializable where Self: NSDate {
    public init(structuredData value: StructuredData) throws {
        switch value {
        case .numberValue(let number):
            self.init(timeIntervalSince1970: number)
        default:
            throw InitializableError.cantBindToNeededType
        }
    }
}

extension NSDate: StructuredDataInitializable { }
```

## Installation

- Add `Mapper` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/Mapper.git", majorVersion: 0, minor: 5),
    ]
)
```

## Support

If you need any help you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community

[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[zewo-badge]: https://img.shields.io/badge/Zewo-0.5-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/Zewo/Mapper.svg?branch=master
[travis-url]: https://travis-ci.org/Zewo/Mapper
[codebeat-badge]: https://codebeat.co/badges/d08bad48-c72e-49e3-a184-68a23063d461
[codebeat-url]: https://codebeat.co/projects/github-com-zewo-mapper