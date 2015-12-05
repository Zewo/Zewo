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
// IMPLIED, INCLUDINbG BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Venice
import Stream

final class TCPStream: StreamType {
    let socket: TCPClientSocket
    let closeChannel = Channel<Void>()

    init(socket: TCPClientSocket) {
        self.socket = socket
    }

    func receive(completion: (Void throws -> [Int8]) -> Void) {
        co {
            self.socket.receive(closeChannel: self.closeChannel, lowWaterMark: 1) { result in
                do {
                    let data = try result()
                    completion({ data })
                } catch TCPError.ConnectionResetByPeer(_, let data) {
                    if data.count > 0 {
                        completion({ data })
                    }
                    self.close()
                } catch {
                    completion({ throw error })
                }
            }
        }
    }

    func send(data: [Int8], completion: (Void throws -> Void) -> Void) {
        co {
            do {
                try self.socket.send(data)
                try self.socket.flush()
                completion({})
            } catch TCPError.ConnectionResetByPeer {
                completion({})
                self.close()
            } catch {
                completion({ throw error })
            }
        }
    }

    func close() {
        socket.close()
    }

    func pipe() -> StreamType {
        closeChannel.send()
        closeChannel.receive()
        return TCPStream(socket: socket)
    }
}
