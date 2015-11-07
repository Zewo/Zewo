// RequestResponseServer.swift
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

struct RequestResponseServer<Parser: RequestParserType, Responder: ResponderType, Serializer: ResponseSerializerType where Parser.Request == Responder.Request, Serializer.Response == Responder.Response> {
    let server: ServerType
    let parser: Parser
    let responder: Responder
    let serializer: Serializer
    
    func start(failure failure: ErrorType -> Void) {
        server.acceptClient { acceptResult in
            acceptResult.success { client in
                self.parser.parseRequest(client) { parseResult in
                    parseResult.success { request in
                        self.responder.respond(request) { response in
                            self.serializer.serializeResponse(client, response: response) { serializeResult in
                                serializeResult.success {
                                    if !self.keepAlive(request) {
                                        client.close()
                                    }
                                }
                                serializeResult.failure { error in
                                    failure(error)
                                    client.close()
                                }
                            }
                        }
                    }
                    parseResult.failure { error in
                        failure(error)
                        client.close()
                    }
                }
            }
            acceptResult.failure(failure)
        }
    }

    func stop() {
        server.stop()
    }
    
    private func keepAlive(request: Responder.Request) -> Bool {
        return (request as? KeepAliveType)?.shouldKeepAlive ?? false
    }
}