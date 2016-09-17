public struct Version {
    public var major: Int
    public var minor: Int

    public init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }
}

extension Version : Hashable {
    public var hashValue: Int {
        return major ^ minor
    }
}

extension Version : Equatable {}

public func == (lhs: Version, rhs: Version) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
