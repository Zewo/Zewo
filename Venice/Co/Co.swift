// Co.swift
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

/// Current time
public var now: Int64 {
    return libmill.now()
}

public let hour: Int64 = 3600000
public let minute: Int64 = 60000
public let second: Int64 = 1000
public let millisecond: Int64 = 1

public typealias Deadline = Int64
let NoDeadline: Deadline = -1

/// Runs the expression in a lightweight coroutine
public func co(@autoclosure(escaping) routine: Void -> Void) {
    libmill.co(routine)
}

/// Runs the expression in a lightweight coroutine
public func co(routine: Void -> Void) {
    libmill.co(routine)
}

/// Runs the expression in a lightweight coroutine
public func after(napDuration: Int64, routine: Void -> Void) {
    libmill.co {
        nap(napDuration)
        routine()
    }
}

/// Preallocates coroutine stacks. Returns the number of stacks that it actually managed to allocate.
public func preallocateCoroutineStacks(stackCount stackCount: Int, stackSize: Int, channelValueMaxSize: Int) -> Int {
    return Int(goprepare(Int32(stackCount), stackSize, channelValueMaxSize))
}

/// Sleeps for duration
public func nap(duration: Int64) {
    mill_msleep(now + duration)
}

/// Wakes up at deadline
public func wakeUp(deadline: Deadline) {
    mill_msleep(deadline)
}

/// Passes control to other coroutines
public var yield: Void {
    mill_yield()
}
