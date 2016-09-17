public struct Trie<Element : Comparable, Payload> {
    let prefix: Element?
    var payload: Payload?
    var ending: Bool
    var children: [Trie<Element, Payload>]

    init() {
        self.prefix = nil
        self.payload = nil
        self.ending = false
        self.children = []
    }

    init(prefix: Element, payload: Payload?, ending: Bool, children: [Trie<Element, Payload>]) {
        self.prefix = prefix
        self.payload = payload
        self.ending = ending
        self.children = children
        self.children.sort()
    }
}

public func ==<Element, Payload>(lhs: Trie<Element, Payload>, rhs: Trie<Element, Payload>) -> Bool where Element : Comparable {
    return lhs.prefix == rhs.prefix
}

public func < <Element, Payload>(lhs: Trie<Element, Payload>, rhs: Trie<Element, Payload>) -> Bool where Element : Comparable {
    switch (lhs.prefix, rhs.prefix) {
    case (.some(let l), .some(let r)):
        return l < r
    default:
        return false
    }
}

extension Trie : Comparable { }

extension Trie : CustomStringConvertible {
    public var description: String {
        return pretty(depth: 0)
    }

    func pretty(depth: Int) -> String {
        let key: String
        if let k = self.prefix {
            key = String(describing: k)
        } else {
            key = "head"
        }

        let payload: String
        if let p = self.payload {
            payload = ":" + String(describing: p)
        } else {
            payload = ""
        }

        let children = self.children
            .map { $0.pretty(depth: depth + 1) }
            .reduce("", { $0 + $1})

        let pretty = "- \(key)\(payload)" + "\n" + String(children)

        let indentation = (0..<depth).reduce("", {$0.0 + "  "})

        return "\(indentation)\(pretty)"
    }
}

extension Trie {
    mutating func insert<SequenceType : Sequence>(_ sequence: SequenceType, payload: Payload? = nil) where SequenceType.Iterator.Element == Element {
        insert(sequence.makeIterator(), payload: payload)
    }

    mutating func insert<Iterator : IteratorProtocol>(_ iterator: Iterator, payload: Payload? = nil) where Iterator.Element == Element {

        var iterator = iterator

        guard let element = iterator.next() else {
            self.payload = self.payload ?? payload
            self.ending = true

            return
        }

        for (index, child) in children.enumerated() {
            var child = child
            if child.prefix == element {
                child.insert(iterator, payload: payload)
                self.children[index] = child
                self.children.sort()
                return
            }
        }

        var new = Trie<Element, Payload>(prefix: element, payload: nil, ending: false, children: [])

        new.insert(iterator, payload: payload)

        self.children.append(new)

        self.children.sort()
    }
}

extension Trie {
    func findLast<Iterator : IteratorProtocol>(_ iterator: Iterator) -> Trie<Element, Payload>? where Iterator.Element == Element {

        var iterator = iterator

        guard let target = iterator.next() else {
            guard ending == true else { return nil }
            return self
        }

        // binary search
        var lower = 0
        var higher = children.count - 1

        while lower <= higher {
            let middle = (lower + higher) / 2
            let child = children[middle]
            guard let current = child.prefix else { continue }

            if current == target {
                return child.findLast(iterator)
            }

            if current < target {
                lower = middle + 1
            }

            if current > target {
                higher = middle - 1
            }
        }

        return nil
    }
}

extension Trie {
    func findPayload<SequenceType : Sequence>(_ sequence: SequenceType) -> Payload? where SequenceType.Iterator.Element == Element {
        return findPayload(sequence.makeIterator())
    }
    func findPayload<Iterator : IteratorProtocol>(_ iterator: Iterator) -> Payload? where Iterator.Element == Element {
        return findLast(iterator)?.payload
    }
}

extension Trie {
    func contains<SequenceType : Sequence>(_ sequence: SequenceType) -> Bool where SequenceType.Iterator.Element == Element {
        return contains(sequence.makeIterator())
    }

    func contains<Iterator : IteratorProtocol>(_ iterator: Iterator) -> Bool where Iterator.Element == Element {
        return findLast(iterator) != nil
    }
}

extension Trie {
    mutating func sort(by isOrderedBefore: (Trie<Element, Payload>, Trie<Element, Payload>) -> Bool) {
        self.children = children.map { child in
            var child = child
            child.sort(by: isOrderedBefore)
            return child
        }
        
        self.children.sort(by: isOrderedBefore)
    }
}
