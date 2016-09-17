import XCTest
import ReflectionTests

XCTMain([
    testCase(InternalTests.allTests),
    testCase(MappableExampleTests.allTests),
    testCase(PerformanceTests.allTests),
    testCase(PublicTests.allTests),
])
