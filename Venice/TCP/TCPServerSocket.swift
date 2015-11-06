// TCPServerSocket.swift
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

import libmill

public final class TCPServerSocket {
    private var socket: tcpsock

    public var port: Int {
        return Int(tcpport(self.socket))
    }

    public private(set) var closed = false

    public init(ip: IP, backlog: Int = 10) throws {
        self.socket = tcplisten(ip.address, Int32(backlog))

        if errno != 0 {
            closed = true
            throw TCPError.lastError
        }
    }

    public init(fileDescriptor: Int32) throws {
        self.socket = tcpattach(fileDescriptor, 1)

        if errno != 0 {
            closed = true
            throw TCPError.lastError
        }
    }

    deinit {
        close()
    }

    public func accept(deadline: Deadline = NoDeadline) throws -> TCPClientSocket {
        if closed {
            throw TCPError.Generic(description: "Closed socket")
        }

        let clientSocket = tcpaccept(socket, deadline)

        if errno != 0 {
            throw TCPError.lastError
        }

        return TCPClientSocket(socket: clientSocket)
    }

    public func attach(fileDescriptor: Int32) throws {
        if !closed {
            tcpclose(socket)
        }

        socket = tcpattach(fileDescriptor, 1)

        if errno != 0 {
            closed = true
            throw TCPError.lastError
        }

        closed = false
    }

    public func detach() throws -> Int32 {
        if closed {
            throw TCPError.Generic(description: "Closed socket")
        }

        closed = true
        return tcpdetach(socket)
    }

    public func close() {
        if !closed {
            closed = true
            tcpclose(socket)
        }
    }
}

extension TCPServerSocket {
    public func acceptClients(accepted: TCPClientSocket -> Void) throws {
        var sequentialErrorsCount = 0

        while !closed {
            do {
                let clientSocket = try accept()
                sequentialErrorsCount = 0
                co(accepted(clientSocket))
            } catch {
                ++sequentialErrorsCount
                if sequentialErrorsCount >= 10 {
                    throw error
                }
            }
        }
    }
}
