import XCTest
import HTTPTests

XCTMain([
    testCase(RequestContentTests.allTests),
    testCase(ResponseContentTests.allTests),
    testCase(AttributedCookieTests.allTests),
    testCase(BodyTests.allTests),
    testCase(CookieTests.allTests),
    testCase(MessageTests.allTests),
    testCase(RequestTests.allTests),
    testCase(ResponseTests.allTests),
    testCase(BasicAuthMiddlewareTests.allTests),
    testCase(ContentNegotiationMiddlewareTests.allTests),
    testCase(LogMiddlewareTests.allTests),
    testCase(RecoveryMiddlewareTests.allTests),
    testCase(RedirectMiddlewareTests.allTests),
    testCase(SessionMiddlewareTests.allTests),
    testCase(RequestParserTests.allTests),
    testCase(ResponseParserTests.allTests),
    testCase(ResourceTests.allTests),
    testCase(RouterTests.allTests),
    testCase(RoutesTests.allTests),
    testCase(TrieRouteMatcherTests.allTests),
    testCase(HTTPSerializerTests.allTests),
    testCase(ServerTests.allTests),
])
