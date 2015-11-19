// TCPStream.swift
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

import Venice

final class TCPStream : TCPStreamType {
    let socket: TCPClientSocket

    init(socket: TCPClientSocket) {
        self.socket = socket
    }

    func receive(completion: (data: [Int8], error: ErrorType?) -> Void) {
        do {
            try socket.receive(lowWaterMark: 1) { data in
                completion(data: data, error: nil)
            }
        } catch TCPError.ConnectionResetByPeer(_, let data) {
            if data.count > 0 {
                completion(data: data, error: nil)
            }
            close()
        } catch {
            completion(data: [], error: error)
        }
    }

    func send(data: [Int8], completion: (error: ErrorType?) -> Void) {
        do {
            try socket.send(data)
            try socket.flush()
            completion(error: nil)
        } catch TCPError.ConnectionResetByPeer {
            completion(error: nil)
            close()
        } catch {
            completion(error: error)
        }
    }

    func close() {
        socket.close()
    }
}
