import XCTest
@testable import POSIXTests

XCTMain([
    testCase(POSIXTests.allTests),
    testCase(EnvironmentTests.allTests),
])
