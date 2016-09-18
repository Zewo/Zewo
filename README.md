<p align="center">
    <a href="http://zewo.io"><img src="https://raw.githubusercontent.com/Zewo/Zewo/master/Images/zewo.png" alt="Zewo"/></a>
</p>

<p align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://tldrlegal.com/license/mit-license"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License" /></a>
    <a href="http://slack.zewo.io"><img src="https://zewo-slackin.herokuapp.com/badge.svg" alt="Slack" /></a>
    <a href="https://travis-ci.org/Zewo/Zewo"><img src="https://travis-ci.org/Zewo/Zewo.svg?branch=master" alt="Travis" /></a>
    <a href="https://codecov.io/gh/Zewo/Zewo"><img src="https://codecov.io/gh/Zewo/Zewo/branch/master/graph/badge.svg" alt="Codecov" /></a>
    <a href="#backers"><img src="https://opencollective.com/zewo/backers/badge.svg"></a>
    <a href="#sponsors"><img src="https://opencollective.com/zewo/sponsors/badge.svg"></a>
</p>

<p align="center">
      <a href="#getting-started">Getting Started</a>
    • <a href="#support">Support</a>
    • <a href="#community">Community</a>
    • <a href="#contribution">Contribution</a>
</p>

# Zewo

**Zewo** is a set of libraries for server side development. With **Zewo** you can write your web app, REST API, command line tool, database driver, etc. Our goal is to create an ecosystem around the modules and tools we provide so you can focus on developing your application or library, instead of doing everything from scratch.

Check out our [organization](https://github.com/Zewo) for the modules.

## Test Coverage

[![Test Coverage][codecov-sunburst]][codecov-url]

The inner-most circle is the entire project, moving away from the center are folders then, finally, a single file. The size and color of each slice is represented by the number of statements and the coverage, respectively.

## Getting Started

### Install Swiftenv

[Swiftenv](https://github.com/kylef/swiftenv) allows you to easily install, and switch between multiple versions of Swift. You can install swiftenv following official [instructions](https://github.com/kylef/swiftenv#installation).

⚠️ With **homebrew** use `brew install kylef/formulae/swiftenv --HEAD`.

### Install Swift 3.0 Release

Once you have it, install the Swift 3.0 Release

```sh
swiftenv install 3.0
```

### Create your first Zewo web application

First we need to create a directory for our app.

```sh
mkdir hello && cd hello
```

Now we select Swift 3.0 Release with Swiftenv and initialize the project with the Swift Package Manager (**SwiftPM**).

```sh
swiftenv local 3.0
swift package init --type executable
```

This command will create the basic structure for our app.

```
.
├── .gitignore
├── .swift-version
├── Package.swift
├── Sources
│   └── main.swift
└── Tests
```

Open `Package.swift` with your favorite editor and add `HTTPServer` as a dependency.

```swift
import PackageDescription

let package = Package(
    name: "hello",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/HTTPServer.git", majorVersion: 0, minor: 13),
    ]
)
```

### Do your magic

Open `main.swift` and make it look like this:

```swift
import HTTPServer

let router = BasicRouter { route in
    route.get("/hello") { request in
        return Response(body: "Hello, world!")
    }
}

let server = try Server(configuration: ["port": 8080], responder: router)
try server.start()
```

This code:

- Imports the `HTTPServer` module
- Creates a `BasicRouter`
- Configures a route matching any `Request` with **GET** as the HTTP method and **/hello** as the path.
- Returns a `Response` with `"Hello, world!"` as the body for requests matching the route.
- Creates an HTTP server that listens on port `8080`.
- Starts the server.

### Build and run
Now let's build the app.

```sh
swift build
```

After it compiles, run it.

```sh
.build/debug/hello
```

![Terminal Server](Images/Terminal-server.png)

Now open your favorite browser and go to [http://localhost:8080/hello](http://localhost:8080/hello). You should see **Hello, world!** in your browser's window. 😊

![Safari Hello](Images/Safari-hello.png)

By default the server will log the requests/responses.

![Terminal Log](Images/Terminal-log.png)

Press `control + c` to stop the server.

### Xcode

Using an IDE can be a huge boost to productivity. Luckily, **SwiftPM** has Xcode project generation support built in.

To generate your Zewo Xcode project simply run:

```sh
swift package generate-xcodeproj
```

Open your Xcode project by double clicking it on Finder or with:

```sh
open hello.xcodeproj
```

To run the application select the command line application scheme `hello` on Xcode.

![Xcode Scheme](Images/Xcode-scheme.png)

Now click the run button ► or use the shortcut `⌘R`. You should see the server running directly from your Xcode.

![Xcode Console](Images/Xcode-console.png)

You can set breakpoints in your code and debug it as usual.

![Xcode Debug](Images/Xcode-debug.png)

To stop the server just click the stop button ■ or use the shortcut `⌘.`.

### What's next?

Check out our [organization](https://github.com/Zewo) for more. You can also take a look at our [documentation](http://zewo.readme.io). If you have any doubts you can reach us at our [slack](http://slack.zewo.io). We're very active and always ready to help.

## Support

If you have **any** trouble create a Github [issue](https://github.com/QuarkX/Quark/issues/new) and we'll do everything we can to help you. When stating your issue be sure to add enough details and reproduction steps so we can help you faster. If you prefer you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel too.

## Community

[![Slack][slack-image]][slack-url]

We have an amazing community of open and welcoming developers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## Contribution

Yo! Want to be a part of **Zewo**? Check out our [Contribution Guidelines](CONTRIBUTING.md).

## Backers

Support us with a monthly donation and help us continue our activities. [[Become a backer](https://opencollective.com/zewo#backer)]

<a href="https://opencollective.com/zewo/backer/0/website" target="_blank"><img src="https://opencollective.com/zewo/backer/0/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/1/website" target="_blank"><img src="https://opencollective.com/zewo/backer/1/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/2/website" target="_blank"><img src="https://opencollective.com/zewo/backer/2/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/3/website" target="_blank"><img src="https://opencollective.com/zewo/backer/3/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/4/website" target="_blank"><img src="https://opencollective.com/zewo/backer/4/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/5/website" target="_blank"><img src="https://opencollective.com/zewo/backer/5/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/6/website" target="_blank"><img src="https://opencollective.com/zewo/backer/6/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/7/website" target="_blank"><img src="https://opencollective.com/zewo/backer/7/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/8/website" target="_blank"><img src="https://opencollective.com/zewo/backer/8/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/9/website" target="_blank"><img src="https://opencollective.com/zewo/backer/9/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/10/website" target="_blank"><img src="https://opencollective.com/zewo/backer/10/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/11/website" target="_blank"><img src="https://opencollective.com/zewo/backer/11/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/12/website" target="_blank"><img src="https://opencollective.com/zewo/backer/12/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/13/website" target="_blank"><img src="https://opencollective.com/zewo/backer/13/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/14/website" target="_blank"><img src="https://opencollective.com/zewo/backer/14/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/15/website" target="_blank"><img src="https://opencollective.com/zewo/backer/15/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/16/website" target="_blank"><img src="https://opencollective.com/zewo/backer/16/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/17/website" target="_blank"><img src="https://opencollective.com/zewo/backer/17/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/18/website" target="_blank"><img src="https://opencollective.com/zewo/backer/18/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/19/website" target="_blank"><img src="https://opencollective.com/zewo/backer/19/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/20/website" target="_blank"><img src="https://opencollective.com/zewo/backer/20/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/21/website" target="_blank"><img src="https://opencollective.com/zewo/backer/21/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/22/website" target="_blank"><img src="https://opencollective.com/zewo/backer/22/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/23/website" target="_blank"><img src="https://opencollective.com/zewo/backer/23/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/24/website" target="_blank"><img src="https://opencollective.com/zewo/backer/24/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/25/website" target="_blank"><img src="https://opencollective.com/zewo/backer/25/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/26/website" target="_blank"><img src="https://opencollective.com/zewo/backer/26/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/27/website" target="_blank"><img src="https://opencollective.com/zewo/backer/27/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/28/website" target="_blank"><img src="https://opencollective.com/zewo/backer/28/avatar.svg"></a>
<a href="https://opencollective.com/zewo/backer/29/website" target="_blank"><img src="https://opencollective.com/zewo/backer/29/avatar.svg"></a>

## Sponsors

Become a sponsor and get your logo on our website Zewo.io and on our README on Github with a link to your site. [[Become a sponsor](https://opencollective.com/zewo#sponsor)]

<a href="https://opencollective.com/zewo/sponsor/0/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/1/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/2/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/3/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/4/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/5/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/6/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/7/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/8/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/9/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/9/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/10/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/10/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/11/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/11/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/12/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/12/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/13/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/13/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/14/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/14/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/15/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/15/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/16/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/16/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/17/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/17/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/18/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/18/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/19/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/19/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/20/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/20/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/21/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/21/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/22/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/22/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/23/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/23/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/24/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/24/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/25/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/25/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/26/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/26/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/27/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/27/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/28/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/28/avatar.svg"></a>
<a href="https://opencollective.com/zewo/sponsor/29/website" target="_blank"><img src="https://opencollective.com/zewo/sponsor/29/avatar.svg"></a>

## License

All **Zewo** modules are released under the MIT license. See [LICENSE](LICENSE) for details.

[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-url]: http://slack.zewo.io
[codecov-url]: https://codecov.io/gh/Zewo/Zewo
[codecov-sunburst]: https://codecov.io/gh/Zewo/Zewo/branch/master/graphs/sunburst.svg