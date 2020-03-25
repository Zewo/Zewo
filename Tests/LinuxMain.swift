import XCTest
import CoreTests
import HTTPTests
import IOTests
import MediaTests
    
XCTMain([
    testCase(StringTests.allTests),
    testCase(SystemErrorTests.allTests),
    testCase(ClientTests.allTests),
    testCase(ServerTests.allTests),
    testCase(IPTests.allTests),
    testCase(TCPTests.allTests),
    testCase(TLSTests.allTests),
    testCase(JSONTests.allTests),
    testCase(MapTests.allTests),
])
