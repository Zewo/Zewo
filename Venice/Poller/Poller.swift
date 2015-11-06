// Poller.swift
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

public struct PollEvent : OptionSetType {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let Read  = PollEvent(rawValue: Int(FDW_IN))
    public static let Write = PollEvent(rawValue: Int(FDW_OUT))
}

public struct PollResult : OptionSetType {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let Timeout = PollResult(rawValue: 0)
    public static let Read    = PollResult(rawValue: Int(FDW_IN))
    public static let Write   = PollResult(rawValue: Int(FDW_OUT))
    public static let Error   = PollResult(rawValue: Int(FDW_ERR))
}

/// Polls file descriptor for events
public func pollFileDescriptor(fileDescriptor: Int32, events: PollEvent, deadline: Deadline = NoDeadline) -> PollResult {
    let event = mill_fdwait(fileDescriptor, Int32(events.rawValue), deadline)
    return PollResult(rawValue: Int(event))
}