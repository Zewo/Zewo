// FallibleReceivingChannel.swift
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

public final class FallibleReceivingChannel<T> : FallibleReceivable {
    private let channel: FallibleChannel<T>
    
    init(_ channel: FallibleChannel<T>) {
        self.channel = channel
    }

    public func receiveResult(result: ChannelResult<T>) {
        return channel.receiveResult(result)
    }
    
    public func receive(value: T) {
        return channel.receive(value)
    }

    func receive(value: T, clause: UnsafeMutablePointer<Void>, index: Int) {
        return channel.receive(value, clause: clause, index: index)
    }
    
    public func receiveError(error: ErrorType) {
        return channel.receiveError(error)
    }

    func receive(error: ErrorType, clause: UnsafeMutablePointer<Void>, index: Int) {
        return channel.receive(error, clause: clause, index: index)
    }
    
    var closed: Bool {
        return channel.closed
    }
}