#if os(Linux)

import XCTest
@testable import MapperTestSuite

XCTMain([
	testCase(NormalValueTests.allTests),
	testCase(OptionalValueTests.allTests),
	testCase(RawRepresentableValueTests.allTests),
	testCase(InitializableTests.allTests),
	testCase(MappableValueTests.allTests)
])

#endif