struct Stack<T> {
    private(set) var stack: [T] = []
    
    init() {}
    
    var count: Int {
        return stack.count
    }
    
    var top: T {
        precondition(stack.count > 0, "Empty container stack.")
        return stack.last!
    }
    
    mutating func withTop(body: (inout T) throws -> Void) rethrows -> Void {
        var top = self.top
        try body(&top)
        stack[stack.count - 1] = top
    }
    
    mutating func push(_ value: T) {
        stack.append(value)
    }
    
    @discardableResult mutating func pop() -> T {
        precondition(stack.count > 0, "Empty map stack.")
        return stack.popLast()!
    }
    
    mutating func pushPop<R>(_ value: T, body: () throws -> R) rethrows -> R {
        push(value)
        let result: R = try body()
        pop()
        return result
    }
}
