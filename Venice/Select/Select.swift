// Select.swift
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

protocol SelectCase {
    func register(clause: UnsafeMutablePointer<Void>, index: Int)
    func execute()
}

final class ChannelReceiveCase<T> : SelectCase {
    let channel: Channel<T>
    let closure: T -> Void

    init(channel: Channel<T>, closure: T -> Void) {
        self.channel = channel
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.registerSend(clause, index: index)
    }

    func execute() {
        if let value = channel.getValueFromBuffer() {
            closure(value)
        }
    }
}

final class SendingChannelReceiveCase<T> : SelectCase {
    let channel: SendingChannel<T>
    let closure: T -> Void

    init(channel: SendingChannel<T>, closure: T -> Void) {
        self.channel = channel
        self.closure = closure
    }
    
    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.registerSend(clause, index: index)
    }
    
    func execute() {
        if let value = channel.getValueFromBuffer() {
            closure(value)
        }
    }
}

final class FallibleChannelReceiveCase<T> : SelectCase {
    let channel: FallibleChannel<T>
    var closure: ChannelResult<T> -> Void

    init(channel: FallibleChannel<T>, closure: ChannelResult<T> -> Void) {
        self.channel = channel
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.registerSend(clause, index: index)
    }

    func execute() {
        if let result = channel.getResultFromBuffer() {
            closure(result)
        }
    }
}

final class FallibleSendingChannelReceiveCase<T> : SelectCase {
    let channel: FallibleSendingChannel<T>
    var closure: ChannelResult<T> -> Void

    init(channel: FallibleSendingChannel<T>, closure: ChannelResult<T> -> Void) {
        self.channel = channel
        self.closure = closure
    }
    
    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.registerSend(clause, index: index)
    }
    
    func execute() {
        if let result = channel.getResultFromBuffer() {
            closure(result)
        }
    }
}

final class ChannelSendCase<T> : SelectCase {
    let channel: Channel<T>
    var value: T
    let closure: Void -> Void

    init(channel: Channel<T>, value: T, closure: Void -> Void) {
        self.channel = channel
        self.value = value
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(value, clause: clause, index: index)
    }

    func execute() {
        closure()
    }
}

final class ReceivingChannelSendCase<T> : SelectCase {
    let channel: ReceivingChannel<T>
    var value: T
    let closure: Void -> Void

    init(channel: ReceivingChannel<T>, value: T, closure: Void -> Void) {
        self.channel = channel
        self.value = value
        self.closure = closure
    }
    
    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(value, clause: clause, index: index)
    }
    
    func execute() {
        closure()
    }
}

final class FallibleChannelSendCase<T> : SelectCase {
    let channel: FallibleChannel<T>
    let value: T
    let closure: Void -> Void

    init(channel: FallibleChannel<T>, value: T, closure: Void -> Void) {
        self.channel = channel
        self.value = value
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(value, clause: clause, index: index)
    }

    func execute() {
        closure()
    }
}

final class FallibleReceivingChannelSendCase<T> : SelectCase {
    let channel: FallibleReceivingChannel<T>
    let value: T
    let closure: Void -> Void

    init(channel: FallibleReceivingChannel<T>, value: T, closure: Void -> Void) {
        self.channel = channel
        self.value = value
        self.closure = closure
    }
    
    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(value, clause: clause, index: index)
    }
    
    func execute() {
        closure()
    }
}

final class FallibleChannelSendErrorCase<T> : SelectCase {
    let channel: FallibleChannel<T>
    let error: ErrorType
    let closure: Void -> Void

    init(channel: FallibleChannel<T>, error: ErrorType, closure: Void -> Void) {
        self.channel = channel
        self.error = error
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(error, clause: clause, index: index)
    }

    func execute() {
        closure()
    }
}

final class FallibleReceivingChannelSendErrorCase<T> : SelectCase {
    let channel: FallibleReceivingChannel<T>
    let error: ErrorType
    let closure: Void -> Void

    init(channel: FallibleReceivingChannel<T>, error: ErrorType, closure: Void -> Void) {
        self.channel = channel
        self.error = error
        self.closure = closure
    }
    
    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.receive(error, clause: clause, index: index)
    }
    
    func execute() {
        closure()
    }
}

final class TimeoutCase<T> : SelectCase {
    let channel: Channel<T>
    let closure: Void -> Void

    init(channel: Channel<T>, closure: Void -> Void) {
        self.channel = channel
        self.closure = closure
    }

    func register(clause: UnsafeMutablePointer<Void>, index: Int) {
        channel.registerSend(clause, index: index)
    }

    func execute() {
        closure()
    }
}

public class SelectCaseBuilder {
    var cases: [SelectCase] = []
    var otherwise: (Void -> Void)?

    public func receiveFrom<T>(channel: Channel<T>?, closure: T -> Void) {
        if let channel = channel {
            let selectCase = ChannelReceiveCase(channel: channel, closure: closure)
            cases.append(selectCase)
        }
    }
    
    public func receiveFrom<T>(channel: SendingChannel<T>?, closure: T -> Void) {
        if let channel = channel {
            let selectCase = SendingChannelReceiveCase(channel: channel, closure: closure)
            cases.append(selectCase)
        }
    }

    public func receiveFrom<T>(channel: FallibleChannel<T>?, closure: ChannelResult<T> -> Void) {
        if let channel = channel {
            let selectCase = FallibleChannelReceiveCase(channel: channel, closure: closure)
            cases.append(selectCase)
        }
    }
    
    public func receiveFrom<T>(channel: FallibleSendingChannel<T>?, closure: ChannelResult<T> -> Void) {
        if let channel = channel {
            let selectCase = FallibleSendingChannelReceiveCase(channel: channel, closure: closure)
            cases.append(selectCase)
        }
    }

    public func send<T>(value: T, to channel: Channel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = ChannelSendCase(channel: channel, value: value, closure: closure)
            cases.append(selectCase)
        }
    }
    
    public func send<T>(value: T, to channel: ReceivingChannel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = ReceivingChannelSendCase(channel: channel, value: value, closure: closure)
            cases.append(selectCase)
        }
    }

    public func send<T>(value: T, to channel: FallibleChannel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = FallibleChannelSendCase(channel: channel, value: value, closure: closure)
            cases.append(selectCase)
        }
    }
    
    public func send<T>(value: T, to channel: FallibleReceivingChannel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = FallibleReceivingChannelSendCase(channel: channel, value: value, closure: closure)
            cases.append(selectCase)
        }
    }

    public func throwError<T>(error: ErrorType, into channel: FallibleChannel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = FallibleChannelSendErrorCase(channel: channel, error: error, closure: closure)
            cases.append(selectCase)
        }
    }
    
    public func throwError<T>(error: ErrorType, into channel: FallibleReceivingChannel<T>?, closure: Void -> Void) {
        if let channel = channel where !channel.closed {
            let selectCase = FallibleReceivingChannelSendErrorCase(channel: channel, error: error, closure: closure)
            cases.append(selectCase)
        }
    }

    public func timeout(deadline: Deadline, closure: Void -> Void) {
        let done = Channel<Bool>()
        co {
            wakeUp(deadline)
            done <- true
        }
        let selectCase = TimeoutCase<Bool>(channel: done, closure: closure)
        cases.append(selectCase)
    }

    public func otherwise(closure: Void -> Void) {
        self.otherwise = closure
    }
}

private func select(builder: SelectCaseBuilder) {
    mill_choose_init()

    var clauses: [UnsafeMutablePointer<Void>] = []

    for (index, selectCase) in builder.cases.enumerate() {
        let clause = malloc(mill_clauselen())
        clauses.append(clause)
        selectCase.register(clause, index: index)
    }

    if builder.otherwise != nil {
        mill_choose_otherwise()
    }

    let index = mill_choose_wait()

    if index == -1 {
        builder.otherwise?()
    } else {
        builder.cases[Int(index)].execute()
    }
    
    clauses.forEach(free)
}

public func select(@noescape build: (when: SelectCaseBuilder) -> Void) {
    let builder = SelectCaseBuilder()
    build(when: builder)
    select(builder)
}

public func sel(@noescape build: (when: SelectCaseBuilder) -> Void) {
    select(build)
}

public func forSelect(@noescape build: (when: SelectCaseBuilder, done: Void -> Void) -> Void) {
    let builder = SelectCaseBuilder()
    var keepRunning = true
    func done() {
        keepRunning = false
    }
    while keepRunning {
        let builder = SelectCaseBuilder()
        build(when: builder, done: done)
        select(builder)
    }
}

public func forSel(@noescape build: (when: SelectCaseBuilder, done: Void -> Void) -> Void) {
    forSelect(build)
}
