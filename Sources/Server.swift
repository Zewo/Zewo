// Server.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Core
import HTTP
import Venice

public struct Server: ServerType {
    public let server: TCPServerType
    public let parser: RequestParserType = Parser()
    public let responder: ContextResponderType
    public let serializer: ResponseSerializerType = Serializer()

    struct ContextResponder: ContextResponderType {
        let respond: Request throws -> Response
        func respond(context: Context) {
            let response: Response
            do {
                response = try respond(context.request)
            } catch {
                response = Response(status: .InternalServerError)
            }
            context.respond(response)
        }
    }

    public final class Options {
        public var SSL: SSLServerContextType? = nil
    }

    public init(port: Int, responder: ContextResponderType, options: (Options -> Void)? = nil) {
        let serverOptions = Options()
        options?(serverOptions)
        self.server = TCPServer(
            port: port,
            SSL: serverOptions.SSL
        )
        self.responder = responder
    }

    public init(port: Int, responder: ResponderType, options: (Options -> Void)? = nil) {
        let contextResponder = ContextResponder(respond: responder.respond)
        self.init(port: port, responder: contextResponder, options: options)
    }

    public init(port: Int, respond: Request throws -> Response, options: (Options -> Void)? = nil) {
        let contextResponder = ContextResponder(respond: respond)
        self.init(port: port, responder: contextResponder, options: options)
    }

    public func startInBackground(failure failure: ErrorType -> Void = Server.defaultFailureHandler) {
        co(self.start(failure: failure))
    }
}
