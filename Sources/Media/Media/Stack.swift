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
    
    mutating func push(_ value: T) {
        stack.append(value)
    }
    
    @discardableResult mutating func pop() -> T {
        precondition(stack.count > 0, "Empty map stack.")
        return stack.popLast()!
    }
}
