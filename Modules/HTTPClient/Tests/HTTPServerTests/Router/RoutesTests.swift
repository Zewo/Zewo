import XCTest
@testable import HTTPServer

public class RoutesTests : XCTestCase {
    private func checkRoute(routes: Routes, method: Request.Method, path: String, request: Request, response: Response) throws {
        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        if route.actions.count != 1 {
            XCTFail("Should've created exactly one action.")
        }

        guard let (routeMethod, routeResponder) = route.actions.first else {
            return XCTFail("Should've created exactly one action.")
        }

        XCTAssertEqual(route.path, path)
        XCTAssertEqual(routeMethod, method)
        let routeResponse = try routeResponder.respond(to: request)
        XCTAssertEqual(routeResponse.status, response.status)
    }

    private func checkSimpleRoute(method: Request.Method, function: (Routes) -> ((String, [Middleware], @escaping Respond) -> Void), check: @escaping (Request) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/path"
        let request = Request(method: method)
        let response = Response(status: .ok)

        function(routes)(path, []) { request in
            check(request)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testSimpleRoutes() throws {
        func check(method: Request.Method) -> (Request) -> Void {
            return { request in
                XCTAssertEqual(request.method, method)
            }
        }

        try checkSimpleRoute(
            method: .get,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkSimpleRoute(
            method: .head,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkSimpleRoute(
            method: .post,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkSimpleRoute(
            method: .put,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkSimpleRoute(
            method: .patch,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkSimpleRoute(
            method: .delete,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkSimpleRoute(
            method: .options,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRouteWithOnePathParameter<A : PathParameterConvertible>(method: Request.Method, parameter: A, function: (Routes) -> ((String, [Middleware], @escaping (Request, A) throws -> Response) -> Void), check: @escaping (Request, A) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to add the parameter manually
        request.pathParameters = [
            "a": parameter.pathParameter,
        ]

        function(routes)(path, []) { request, a in
            check(request, a)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithOnePathParameter() throws {
        let parameter = "yo"

        func check(method: Request.Method) -> (Request, String) -> Void {
            return { request, a in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
            }
        }

        try checkRouteWithOnePathParameter(
            method: .get,
            parameter: parameter,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRouteWithOnePathParameter(
            method: .head,
            parameter: parameter,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRouteWithOnePathParameter(
            method: .post,
            parameter: parameter,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRouteWithOnePathParameter(
            method: .put,
            parameter: parameter,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRouteWithOnePathParameter(
            method: .patch,
            parameter: parameter,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRouteWithOnePathParameter(
            method: .delete,
            parameter: parameter,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRouteWithOnePathParameter(
            method: .options,
            parameter: parameter,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRouteWithTwoPathParameters<A : PathParameterConvertible>(method: Request.Method, parameter: A, function: (Routes) -> ((String, [Middleware], @escaping (Request, A, A) throws -> Response) -> Void), check: @escaping (Request, A, A) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to add the parameter manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
        ]

        function(routes)(path, []) { request, a, b in
            check(request, a, b)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithTwoPathParameters() throws {
        let parameter = "yo"

        func check(method: Request.Method) -> (Request, String, String) -> Void {
            return { request, a, b in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(b, parameter)
            }
        }

        try checkRouteWithTwoPathParameters(
            method: .get,
            parameter: parameter,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRouteWithTwoPathParameters(
            method: .head,
            parameter: parameter,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRouteWithTwoPathParameters(
            method: .post,
            parameter: parameter,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRouteWithTwoPathParameters(
            method: .put,
            parameter: parameter,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRouteWithTwoPathParameters(
            method: .patch,
            parameter: parameter,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRouteWithTwoPathParameters(
            method: .delete,
            parameter: parameter,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRouteWithTwoPathParameters(
            method: .options,
            parameter: parameter,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithThreePathParameters<A : PathParameterConvertible>(method: Request.Method, parameter: A, function: (Routes) -> ((String, [Middleware], @escaping (Request, A, A, A) throws -> Response) -> Void), check: @escaping (Request, A, A, A) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b/:c"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to add the parameter manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
            "c": parameter.pathParameter,
        ]

        function(routes)(path, []) { request, a, b, c in
            check(request, a, b, c)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithThreePathParameters() throws {
        let parameter = "yo"

        func check(method: Request.Method) -> (Request, String, String, String) -> Void {
            return { request, a, b, c in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(b, parameter)
                XCTAssertEqual(c, parameter)
            }
        }

        try checkRoutesWithThreePathParameters(
            method: .get,
            parameter: parameter,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithThreePathParameters(
            method: .head,
            parameter: parameter,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithThreePathParameters(
            method: .post,
            parameter: parameter,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithThreePathParameters(
            method: .put,
            parameter: parameter,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithThreePathParameters(
            method: .patch,
            parameter: parameter,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithThreePathParameters(
            method: .delete,
            parameter: parameter,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithThreePathParameters(
            method: .options,
            parameter: parameter,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithFourPathParameters<A : PathParameterConvertible>(method: Request.Method, parameter: A, function: (Routes) -> ((String, [Middleware], @escaping (Request, A, A, A, A) throws -> Response) -> Void), check: @escaping (Request, A, A, A, A) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b/:c/:d"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to add the parameter manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
            "c": parameter.pathParameter,
            "d": parameter.pathParameter,
        ]

        function(routes)(path, []) { request, a, b, c, d in
            check(request, a, b, c, d)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithFourPathParameters() throws {
        let parameter = "yo"

        func check(method: Request.Method) -> (Request, String, String, String, String) -> Void {
            return { request, a, b, c, d in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a.pathParameter, parameter)
                XCTAssertEqual(b.pathParameter, parameter)
                XCTAssertEqual(c.pathParameter, parameter)
                XCTAssertEqual(d.pathParameter, parameter)
            }
        }

        try checkRoutesWithFourPathParameters(
            method: .get,
            parameter: parameter,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithFourPathParameters(
            method: .head,
            parameter: parameter,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithFourPathParameters(
            method: .post,
            parameter: parameter,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithFourPathParameters(
            method: .put,
            parameter: parameter,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithFourPathParameters(
            method: .patch,
            parameter: parameter,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithFourPathParameters(
            method: .delete,
            parameter: parameter,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithFourPathParameters(
            method: .options,
            parameter: parameter,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithContent<T : MapInitializable & MapRepresentable>(method: Request.Method, content: T, function: (Routes) -> ((String, [Middleware], T.Type, @escaping (Request, T) throws -> Response) -> Void), check: @escaping (Request, T) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/path"
        var request = Request(method: method)
        let response = Response(status: .ok)

        request.content = content.map

        function(routes)(path, [], T.self) { request, t in
            check(request, t)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithContent() throws {
        let content = 42

        func check(method: Request.Method) -> (Request, Int) -> Void {
            return { request, t in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(t, content)
            }
        }

        try checkRoutesWithContent(
            method: .get,
            content: content,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithContent(
            method: .head,
            content: content,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithContent(
            method: .post,
            content: content,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithContent(
            method: .put,
            content: content,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithContent(
            method: .patch,
            content: content,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithContent(
            method: .delete,
            content: content,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithContent(
            method: .options,
            content: content,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithOnePathParameterAndContent<A : PathParameterConvertible, T : MapInitializable & MapRepresentable>(method: Request.Method, parameter: A, content: T, function: (Routes) -> ((String, [Middleware], T.Type, @escaping (Request, A, T) throws -> Response) -> Void), check: @escaping (Request, A, T) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to set pathParameters manually
        request.pathParameters = [
            "a": parameter.pathParameter,
        ]

        // We don't have content negotiation middleware we have to set content manually
        request.content = content.map

        function(routes)(path, [], T.self) { request, a, t in
            check(request, a, t)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithOnePathParameterAndContent() throws {
        let parameter = "yo"
        let content = 42

        func check(method: Request.Method) -> (Request, String, Int) -> Void {
            return { request, a, t in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(t, content)
            }
        }

        try checkRoutesWithOnePathParameterAndContent(
            method: .get,
            parameter: parameter,
            content: content,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .head,
            parameter: parameter,
            content: content,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .post,
            parameter: parameter,
            content: content,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .put,
            parameter: parameter,
            content: content,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .patch,
            parameter: parameter,
            content: content,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .delete,
            parameter: parameter,
            content: content,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithOnePathParameterAndContent(
            method: .options,
            parameter: parameter,
            content: content,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithTwoPathParametersAndContent<A : PathParameterConvertible, T : MapInitializable & MapRepresentable>(method: Request.Method, parameter: A, content: T, function: (Routes) -> ((String, [Middleware], T.Type, @escaping (Request, A, A, T) throws -> Response) -> Void), check: @escaping (Request, A, A, T) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to set pathParameters manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
        ]

        // We don't have content negotiation middleware we have to set content manually
        request.content = content.map

        function(routes)(path, [], T.self) { request, a, b, t in
            check(request, a, b, t)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithTwoPathParametersAndContent() throws {
        let parameter = "yo"
        let content = 42

        func check(method: Request.Method) -> (Request, String, String, Int) -> Void {
            return { request, a, b, t in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(b, parameter)
                XCTAssertEqual(t, content)
            }
        }

        try checkRoutesWithTwoPathParametersAndContent(
            method: .get,
            parameter: parameter,
            content: content,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .head,
            parameter: parameter,
            content: content,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .post,
            parameter: parameter,
            content: content,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .put,
            parameter: parameter,
            content: content,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .patch,
            parameter: parameter,
            content: content,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .delete,
            parameter: parameter,
            content: content,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithTwoPathParametersAndContent(
            method: .options,
            parameter: parameter,
            content: content,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithThreePathParametersAndContent<A : PathParameterConvertible, T : MapInitializable & MapRepresentable>(method: Request.Method, parameter: A, content: T, function: (Routes) -> ((String, [Middleware], T.Type, @escaping (Request, A, A, A, T) throws -> Response) -> Void), check: @escaping (Request, A, A, A, T) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b/:c"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to set pathParameters manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
            "c": parameter.pathParameter,
        ]

        // We don't have content negotiation middleware we have to set content manually
        request.content = content.map

        function(routes)(path, [], T.self) { request, a, b, c, t in
            check(request, a, b, c, t)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithThreePathParametersAndContent() throws {
        let parameter = "yo"
        let content = 42

        func check(method: Request.Method) -> (Request, String, String, String, Int) -> Void {
            return { request, a, b, c, t in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(b, parameter)
                XCTAssertEqual(c, parameter)
                XCTAssertEqual(t, content)
            }
        }

        try checkRoutesWithThreePathParametersAndContent(
            method: .get,
            parameter: parameter,
            content: content,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .head,
            parameter: parameter,
            content: content,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .post,
            parameter: parameter,
            content: content,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .put,
            parameter: parameter,
            content: content,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .patch,
            parameter: parameter,
            content: content,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .delete,
            parameter: parameter,
            content: content,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithThreePathParametersAndContent(
            method: .options,
            parameter: parameter,
            content: content,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    private func checkRoutesWithFourPathParametersAndContent<A : PathParameterConvertible, T : MapInitializable & MapRepresentable>(method: Request.Method, parameter: A, content: T, function: (Routes) -> ((String, [Middleware], T.Type, @escaping (Request, A, A, A, A, T) throws -> Response) -> Void), check: @escaping (Request, A, A, A, A, T) -> Void) throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/:a/:b/:c/:d"
        var request = Request(
            method: method,
            url: URL(string:
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter +
                "/" + parameter.pathParameter
            )!
        )
        let response = Response(status: .ok)

        // We don't have a RouteMatcher so we have to set pathParameters manually
        request.pathParameters = [
            "a": parameter.pathParameter,
            "b": parameter.pathParameter,
            "c": parameter.pathParameter,
            "d": parameter.pathParameter,
        ]

        // We don't have content negotiation middleware we have to set content manually
        request.content = content.map

        function(routes)(path, [], T.self) { request, a, b, c, d, t in
            check(request, a, b, c, d, t)
            return response
        }

        try checkRoute(
            routes: routes,
            method: method,
            path: path,
            request: request,
            response: response
        )
    }

    func testRoutesWithFourPathParametersAndContent() throws {
        let parameter = "yo"
        let content = 42

        func check(method: Request.Method) -> (Request, String, String, String, String, Int) -> Void {
            return { request, a, b, c, d, t in
                XCTAssertEqual(request.method, method)
                XCTAssertEqual(a, parameter)
                XCTAssertEqual(b, parameter)
                XCTAssertEqual(c, parameter)
                XCTAssertEqual(d, parameter)
                XCTAssertEqual(t, content)
            }
        }

        try checkRoutesWithFourPathParametersAndContent(
            method: .get,
            parameter: parameter,
            content: content,
            function: Routes.get,
            check: check(method: .get)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .head,
            parameter: parameter,
            content: content,
            function: Routes.head,
            check: check(method: .head)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .post,
            parameter: parameter,
            content: content,
            function: Routes.post,
            check: check(method: .post)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .put,
            parameter: parameter,
            content: content,
            function: Routes.put,
            check: check(method: .put)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .patch,
            parameter: parameter,
            content: content,
            function: Routes.patch,
            check: check(method: .patch)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .delete,
            parameter: parameter,
            content: content,
            function: Routes.delete,
            check: check(method: .delete)
        )

        try checkRoutesWithFourPathParametersAndContent(
            method: .options,
            parameter: parameter,
            content: content,
            function: Routes.options,
            check: check(method: .options)
        )
    }

    func testMethods() throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/"
        var called = false

        routes.add(methods: [.get, .head], path: path) { request in
            called = true
            switch request.method {
            case .get:
                return Response(status: .ok)
            case .head:
                return Response(status: .badRequest)
            default:
                XCTFail()
                throw HTTPError.internalServerError
            }
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        if route.actions.count != 2 {
            XCTFail("Should've created two actions.")
        }

        XCTAssertEqual(route.path, path)
        var response = try route.respond(to: Request(method: .get, url: "/")!)
        XCTAssertEqual(response.status, .ok)
        XCTAssert(called)

        called = false
        XCTAssertEqual(route.path, path)
        response = try route.respond(to: Request(method: .head, url: "/")!)
        XCTAssertEqual(response.status, .badRequest)
        XCTAssert(called)
    }

    func testFallback() throws {
        let routes = Routes(staticFilesPath: "")

        var called = false

        routes.fallback { request in
            called = true
            return Response()
        }

        let response = try routes.fallback.respond(to: Request())
        XCTAssertTrue(routes.routes.isEmpty)
        XCTAssertEqual(response.status, .ok)
        XCTAssert(called)
    }

    func testRouteFallback() throws {
        let routes = Routes(staticFilesPath: "")

        let path = "/"
        var called = false

        routes.fallback(path) { request in
            XCTFail()
            return Response()
        }

        routes.fallback(path) { request in
            called = true
            return Response(status: .methodNotAllowed)
        }

        routes.get(path) { request in
            called = true
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        if route.actions.count != 1 {
            XCTFail("Should've created exactly one action.")
        }

        XCTAssertEqual(route.path, path)
        var response = try route.respond(to: Request(method: .get, url: "/")!)
        XCTAssertEqual(response.status, .ok)
        XCTAssert(called)

        called = false
        XCTAssertEqual(route.path, path)
        response = try route.respond(to: Request(method: .head, url: "/")!)
        XCTAssertEqual(response.status, .methodNotAllowed)
        XCTAssert(called)
    }

    func testRoutesWithouthContent() throws {
        let routes = Routes(staticFilesPath: "")

        routes.get("/") { (_, t: Map) in
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertThrowsError(try route.respond(to: Request(method: .get)))
    }

    func testRoutesOnePathParameterWithouthContent() throws {
        let routes = Routes(staticFilesPath: "")

        var request = Request(url: URL(string: "/a")!)
        request.pathParameters = [
            "a": "a",
        ]

        routes.get("/:a") { (_, a: String, t: Map) in
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertThrowsError(try route.respond(to: request))
    }

    func testRoutesTwoPathParameterWithouthContent() throws {
        let routes = Routes(staticFilesPath: "")

        var request = Request(url: "/a/b")!
        request.pathParameters = [
            "a": "a",
            "b": "b",
        ]

        routes.get("/:a/:b") { (_, a: String, b: String, t: Map) in
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertThrowsError(try route.respond(to: request))
    }

    func testRoutesThreePathParameterWithouthContent() throws {
        let routes = Routes(staticFilesPath: "")

        var request = Request(url: "/a/b/c")!
        request.pathParameters = [
            "a": "a",
            "b": "b",
            "c": "c",
        ]

        routes.get("/:a/:b/:c") { (_, a: String, b: String, c: String, t: Map) in
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertThrowsError(try route.respond(to: request))
    }

    func testRoutesFourPathParameterWithouthContent() throws {
        let routes = Routes(staticFilesPath: "")

        var request = Request(url: "/a/b/c/d")!
        request.pathParameters = [
            "a": "a",
            "b": "b",
            "c": "c",
            "d": "d",
        ]

        routes.get("/:a/:b/:c/:d") { (_, a: String, b: String, c: String, d: String, t: Map) in
            return Response()
        }

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertThrowsError(try route.respond(to: request))
    }

    func testInvalidPathParameterCount() {
        // These work on Xcode locally but not on Travis
#if Xcode
//        let pid = fork()
//        XCTAssert(pid >= 0)
//        if pid == 0 {
//            alarm(1)
//            let routes = Routes(staticFilesPath: "")
//            signal(SIGABRT) { _ in
//                _exit(0)
//            }
//            routes.get("/") { (_, a: String, t: Map) in
//                return Response()
//            }
//            XCTFail()
//        }
//        var exitCode: Int32 = 0
//        XCTAssert(waitpid(pid, &exitCode, 0) != 0)
//        XCTAssert(exitCode == 0)
#endif
    }

    func testNonUniquePathParameters() {
        // These work on Xcode locally but not on Travis
        #if Xcode
//            let pid = fork()
//            XCTAssert(pid >= 0)
//            if pid == 0 {
//                alarm(1)
//                let routes = Routes(staticFilesPath: "")
//                signal(SIGILL) { _ in
//                    _exit(0)
//                }
//                routes.get("/:a/:a") { (_, a: String, b: String, t: Map) in
//                    return Response()
//                }
//                XCTFail()
//            }
//            var exitCode: Int32 = 0
//            XCTAssert(waitpid(pid, &exitCode, 0) != 0)
//            XCTAssert(exitCode == 0)
        #endif
    }

    func testComposition() throws {
        let router = BasicRouter { routes in
            routes.add(method: .get, path: "/bar") { _ in
                return Response()
            }
        }

        let routes = Routes(staticFilesPath: "")

        routes.compose("/foo", router: router)

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertEqual(route.path, "/foo/bar")
        let response = try route.respond(to: Request(method: .get))
        XCTAssertEqual(response.status, .ok)
    }

    func testResourceComposition() throws {
        let resource = BasicResource { routes in
            routes.add(method: .get, path: "/bar") { _ in
                return Response()
            }
        }

        let routes = Routes(staticFilesPath: "")

        routes.compose("/foo", resource: resource)

        if routes.routes.count != 1 {
            XCTFail("Should've created exactly one route.")
        }

        guard let route = routes.routes.first else {
            return XCTFail("Should've created exactly one route.")
        }

        XCTAssertEqual(route.path, "/foo/bar")
        let response = try route.respond(to: Request(method: .get))
        XCTAssertEqual(response.status, .ok)
    }
}

extension RoutesTests {
    public static var allTests: [(String, (RoutesTests) -> () throws -> Void)] {
        return [
            ("testSimpleRoutes", testSimpleRoutes),
            ("testRoutesWithOnePathParameter", testRoutesWithOnePathParameter),
            ("testRoutesWithTwoPathParameters", testRoutesWithTwoPathParameters),
            ("testRoutesWithThreePathParameters", testRoutesWithThreePathParameters),
            ("testRoutesWithFourPathParameters", testRoutesWithFourPathParameters),
            ("testRoutesWithContent", testRoutesWithContent),
            ("testRoutesWithOnePathParameterAndContent", testRoutesWithOnePathParameterAndContent),
            ("testRoutesWithTwoPathParametersAndContent", testRoutesWithTwoPathParametersAndContent),
            ("testRoutesWithThreePathParametersAndContent", testRoutesWithThreePathParametersAndContent),
            ("testRoutesWithFourPathParametersAndContent", testRoutesWithFourPathParametersAndContent),
            ("testMethods", testMethods),
            ("testFallback", testFallback),
            ("testRouteFallback", testRouteFallback),
            ("testRoutesWithouthContent", testRoutesWithouthContent),
            ("testRoutesOnePathParameterWithouthContent", testRoutesOnePathParameterWithouthContent),
            ("testRoutesTwoPathParameterWithouthContent", testRoutesTwoPathParameterWithouthContent),
            ("testRoutesThreePathParameterWithouthContent", testRoutesThreePathParameterWithouthContent),
            ("testRoutesFourPathParameterWithouthContent", testRoutesFourPathParameterWithouthContent),
            ("testInvalidPathParameterCount", testInvalidPathParameterCount),
            ("testNonUniquePathParameters", testNonUniquePathParameters),
            ("testComposition", testComposition),
            ("testResourceComposition", testResourceComposition),
        ]
    }
}
