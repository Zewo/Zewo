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

import HTTP
import SSL

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

    public final class ServerOptions {
        var SSLStream: SSLStreamType.Type? = nil
        var SSLContext: SSLContextType? = nil

        public func setSSL(type: SSLStreamType.Type, context: SSLContextType) {
            SSLStream = type
            SSLContext = context
        }
    }

    public init(port: Int, responder: ContextResponderType, options: (ServerOptions -> Void)? = nil) {
        let serverOptions = ServerOptions()
        options?(serverOptions)
        self.server = TCPServer(
            port: port,
            SSLStream: serverOptions.SSLStream,
            SSLContext: serverOptions.SSLContext
        )
        self.responder = responder
    }

    public init(port: Int, responder: ResponderType, options: (ServerOptions -> Void)? = nil) {
        let contextResponder = ContextResponder(respond: responder.respond)
        self.init(port: port, responder: contextResponder, options: options)
    }

    public init(port: Int, respond: Request throws -> Response, options: (ServerOptions -> Void)? = nil) {
        let contextResponder = ContextResponder(respond: respond)
        self.init(port: port, responder: contextResponder, options: options)
    }
}
