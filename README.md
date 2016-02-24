# Zewo

[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]

**Zewo** is a set of libraries aimed at server side development. With Zewo you can write your web app, REST API, command line tool, database driver, etc. Our goal is to create an ecosystem around the modules and tools we provide so you can focus on developing your application or library, instead of doing everything from scratch.

For a more detailed guide than this README provides, check out our great [documentation](http://docs.zewo.io/)

## Installation

Zewo has a few dependencies which the Swift Package cannot set up for you. Nevertheless, it is very simple to install those by yourself.

OS X:

```shell
brew tap zewo/tap
brew install zewo
```

Linux:

```shell
echo "deb [trusted=yes] http://apt.zewo.io/deb ./" | sudo tee --append /etc/apt/sources.list
sudo apt-get update
sudo apt-get install zewo
```

Now that you've done that, you can simply add Zewo to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/Zewo.git", majorVersion: 0, minor: 2)
    ]
)
```

One of our core values is modularity. The `Zewo` package is a convenience *superpackage* that imports most of Zewo's packages. If you don't want to bring everything you can cherry pick desired packages at our [Zewo](https://github.com/Zewo) organization.

## Setting up the development environment (optional)

Xcode is Swift's main IDE that provides excellent support for autocomplete, jump-to-definition, and much more. Unfortunately, the Swift Package Manager does not yet have built-in support to generate Xcode projects. As such, we have made a tool called [zewo-dev](https://github.com/Zewo/zewo-dev) to help us do that.

### Create Xcode project

First, let's configure an Xcode project for you app. Create a directory for Xcode in your app's root directory.

```sh
mkdir Xcode && cd Xcode
```
 
Install [Alcatraz](https://github.com/supermarin/Alcatraz) if you haven't already.

```sh
curl -fsSL https://raw.github.com/alcatraz/Alcatraz/master/Scripts/install.sh | sh
```

Look for **Swift Command Line Application** under Templates in Alcatraz and install it. Restart Xcode and go to `File > New > Projects` and choose **Swift Command Line Application**. Save it on the `Xcode` directory you just created.

Remove the `main.swift` file that was generated and add the `Sources` directory from your app's root directory.

### Install zewo-dev

This tool will clone all repos from Zewo and generate Xcode projects for them.

```sh
gem install zewo-dev
```

Inside the Xcode directory create a directory for Zewo's Xcode projects.

```sh
mkdir Zewo && cd Zewo
```

Pull the repos and generate Xcode projects.

```sh
zewodev init && zewodev make_projects
```

### Add Zewo subprojects

With your app's Xcode project opened, drag and drop the required Xcode projects from Zewo to your project. In our example we should bring `HTTPServer.xcodeproj` and `Router.xcodeproj`.

Go to your app's target `Build Phases > Target Dependencies` and select `HTTPServer` and `Router` frameworks.

Now build and run as usual. After this you can open your favorite browser and go to `localhost:8080/hello`. You should see `hello world` again, but now running from Xcode 😎.

## Community

[![Slack][slack-image]][slack-url]

Join us on [Slack](http://slack.zewo.io)!

License
-------

**Zewo** is released under the MIT license. See LICENSE for details.

[swift-badge]: https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
