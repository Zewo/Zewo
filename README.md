<p align="center">
    <a href="http://zewo.io"><img src="https://raw.githubusercontent.com/Zewo/Zewo/master/Images/zewo.png" height="250" alt="Zewo"/></a>
<br />
<br />
<a href="https://github.com/Zewo/Venice"><img src="https://github.com/Zewo/Venice/blob/master/Images/badge.png?raw=true" height="50" /></a>
</p>

<p align="center">
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat" alt="Swift" /></a>
    <a href="https://tldrlegal.com/license/mit-license"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License" /></a>
    <a href="http://slack.zewo.io"><img src="https://zewo-slackin.herokuapp.com/badge.svg" alt="Slack" /></a>
    <a href="https://travis-ci.org/Zewo/Zewo"><img src="https://api.travis-ci.org/Zewo/Zewo.svg?branch=master" alt="Travis" /></a>
    <img src="https://github.com/Zewo/Zewo/workflows/Swift/badge.svg" />
    <a href="https://codecov.io/gh/Zewo/Zewo"><img src="https://codecov.io/gh/Zewo/Zewo/branch/master/graph/badge.svg" /></a>
    <a href="https://codebeat.co/projects/github-com-zewo-zewo"><img src="https://codebeat.co/badges/d580cc1f-5bdb-494b-8391-d147c7a287a1" alt="Codebeat" /></a>
    <a href="#backers"><img src="https://opencollective.com/zewo/backers/badge.svg"></a>
    <a href="#sponsors"><img src="https://opencollective.com/zewo/sponsors/badge.svg"></a>
</p>

<p align="center">
	   <a href="#what-sets-zewo-apart">Why Zewo?</a>
    • <a href="#support">Support</a>
    • <a href="#community">Community</a>
    • <a href="https://github.com/Zewo/Zewo/blob/master/CONTRIBUTING.md">Contributing</a>
</p>

# Zewo

**Zewo** is a lightweight library for web applications in Swift.

## What sets Zewo apart?

Zewo is **not** a web framework. Zewo is a lightweight library for web applications in Swift. Most server-side Swift projects use Grand Central Dispatch (**GCD**) as the concurrency library of choice. The drawback of using GCD is that its APIs are **asynchronous**. With async code comes **callback hell** and we all know it, it's no fun.

Node.js is the best example of how callbacks can be frustrating. Express.js creator **TJ Holowaychuk** wrote a blog post about [Callback vs Coroutines](https://medium.com/@tjholowaychuk/callbacks-vs-coroutines-174f1fe66127#.3l3pf1xqf) in 2013 and one year later [left the Node.js community](https://medium.com/@tjholowaychuk/farewell-node-js-4ba9e7f3e52b#.okwqsltyx) in favor of Go. There were many reasons for that but one of the main reasons was the concurrency model. Sure we have futures and promises and functional reactive programming. They all mitigate the problem, but the async nature of the code will always be there.

At **Zewo** we use **coroutines**. Coroutines allow concurrency while maintaining **synchronous** APIs. We all learn how to program with synchronous code. We're used to reason about our code synchronously. Being able to use synchronous APIs makes the code much more readable and understandable. Coroutines are also **faster** than threads, because they live in user-space, unlike threads which are managed by the kernel. 

Our implementation of **coroutines** (which is based on [libdill](https://github.com/sustrik/libdill)) is **single-threaded**. This means that you don't have to worry about **locks** or **race conditions**. So your code is **safer** by default. To use all the CPU power available all you have to do is to replicate the work according to the number of logical CPUs available. As an example, this could mean running as many processes of your server as cores in your machine. **Rob Pike**, one of the creators of Go had a talk called [Concurrency is not Parallelism](https://www.youtube.com/watch?v=cN_DpYBzKso) that explains this concept **very** well. Go also has the philosophy:

```
Don't communicate by sharing memory. Share memory by communicating.
```

Like Go, instead of sharing memory and handling state we promote the use of [CSP](https://en.wikipedia.org/wiki/Communicating_sequential_processes)-style concurrency using channels. This pattern brings the abstractions used on the development of distributed systems closer to the way we're used to think about communication. It also aligns well with Swift's mindset of immutability and value types. All of these things contributes to a distinct experince on the server-side Swift.

With **Zewo** you get:

* Go-style concurrency
* Synchronous APIs
* Incredible performance
* Safer applications
* Scalable systems
* Cleaner code
* Proper error handling
* No callback hell
* No race conditions

## Support

If you have **any** trouble create a Github [issue](https://github.com/Zewo/Zewo/issues/new) and we'll do everything we can to help you. When stating your issue be sure to add enough details and reproduction steps so we can help you faster. If you prefer you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel too.

## Community

We have an amazing community of open and welcoming developers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License

All **Zewo** modules are released under the MIT license. See [LICENSE](LICENSE) for details.

[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-url]: http://slack.zewo.io

