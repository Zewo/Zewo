// HTTPStatus.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

public enum HTTPStatus : Equatable {
    // MARK: Informational
    case Continue
    case SwitchingProtocols
    case Processing
    // MARK: Success
    case OK
    case Created
    case Accepted
    case NonAuthoritativeInformation
    case NoContent
    case ResetContent
    case PartialContent
    // MARK: Redirection
    case MultipleChoices
    case MovedPermanently
    case Found
    case SeeOther
    case NotModified
    case UseProxy
    case SwitchProxy
    case TemporaryRedirect
    case PermanentRedirect
    // MARK: Client Error
    case BadRequest
    case Unauthorized
    case PaymentRequired
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case NotAcceptable
    case ProxyAuthenticationRequired
    case RequestTimeout
    case Conflict
    case Gone
    case LengthRequired
    case PreconditionFailed
    case RequestEntityTooLarge
    case RequestURITooLong
    case UnsupportedMediaType
    case RequestedRangeNotSatisfiable
    case ExpectationFailed
    case ImATeapot
    case AuthenticationTimeout
    case EnhanceYourCalm
    case UnprocessableEntity
    case Locked
    case FailedDependency
    case PreconditionRequired
    case TooManyRequests
    case RequestHeaderFieldsTooLarge
    // MARK: Server Error
    case InternalServerError
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    case HTTPVersionNotSupported
    case VariantAlsoNegotiates
    case InsufficientStorage
    case LoopDetected
    case NotExtended
    case NetworkAuthenticationRequired
    // MARK: Raw
    case Raw(statusCode: Int, reasonPhrase: String)

    init(statusCode: Int, reasonPhrase: String = "") {
        switch statusCode {
        case Continue.statusCode:                      self = Continue
        case SwitchingProtocols.statusCode:            self = SwitchingProtocols
        case Processing.statusCode:                    self = Processing

        case OK.statusCode:                            self = OK
        case Created.statusCode:                       self = Created
        case Accepted.statusCode:                      self = Accepted
        case NonAuthoritativeInformation.statusCode:   self = NonAuthoritativeInformation
        case NoContent.statusCode:                     self = NoContent
        case ResetContent.statusCode:                  self = ResetContent
        case PartialContent.statusCode:                self = PartialContent

        case MultipleChoices.statusCode:               self = MultipleChoices
        case MovedPermanently.statusCode:              self = MovedPermanently
        case Found.statusCode:                         self = Found
        case SeeOther.statusCode:                      self = SeeOther
        case NotModified.statusCode:                   self = NotModified
        case UseProxy.statusCode:                      self = UseProxy
        case SwitchProxy.statusCode:                   self = SwitchProxy
        case TemporaryRedirect.statusCode:             self = TemporaryRedirect
        case PermanentRedirect.statusCode:             self = PermanentRedirect

        case BadRequest.statusCode:                    self = BadRequest
        case Unauthorized.statusCode:                  self = Unauthorized
        case PaymentRequired.statusCode:               self = PaymentRequired
        case Forbidden.statusCode:                     self = Forbidden
        case NotFound.statusCode:                      self = NotFound
        case MethodNotAllowed.statusCode:              self = MethodNotAllowed
        case NotAcceptable.statusCode:                 self = NotAcceptable
        case ProxyAuthenticationRequired.statusCode:   self = ProxyAuthenticationRequired
        case RequestTimeout.statusCode:                self = RequestTimeout
        case Conflict.statusCode:                      self = Conflict
        case Gone.statusCode:                          self = Gone
        case LengthRequired.statusCode:                self = LengthRequired
        case PreconditionFailed.statusCode:            self = PreconditionFailed
        case RequestEntityTooLarge.statusCode:         self = RequestEntityTooLarge
        case RequestURITooLong.statusCode:             self = RequestURITooLong
        case UnsupportedMediaType.statusCode:          self = UnsupportedMediaType
        case RequestedRangeNotSatisfiable.statusCode:  self = RequestedRangeNotSatisfiable
        case ExpectationFailed.statusCode:             self = ExpectationFailed
        case ImATeapot.statusCode:                     self = ImATeapot
        case AuthenticationTimeout.statusCode:         self = AuthenticationTimeout
        case EnhanceYourCalm.statusCode:               self = EnhanceYourCalm
        case UnprocessableEntity.statusCode:           self = UnprocessableEntity
        case Locked.statusCode:                        self = Locked
        case FailedDependency.statusCode:              self = FailedDependency
        case PreconditionRequired.statusCode:          self = PreconditionRequired
        case TooManyRequests.statusCode:               self = TooManyRequests
        case RequestHeaderFieldsTooLarge.statusCode:   self = RequestHeaderFieldsTooLarge

        case InternalServerError.statusCode:           self = InternalServerError
        case NotImplemented.statusCode:                self = NotImplemented
        case BadGateway.statusCode:                    self = BadGateway
        case ServiceUnavailable.statusCode:            self = ServiceUnavailable
        case GatewayTimeout.statusCode:                self = GatewayTimeout
        case HTTPVersionNotSupported.statusCode:       self = HTTPVersionNotSupported
        case VariantAlsoNegotiates.statusCode:         self = VariantAlsoNegotiates
        case InsufficientStorage.statusCode:           self = InsufficientStorage
        case LoopDetected.statusCode:                  self = LoopDetected
        case NotExtended.statusCode:                   self = NotExtended
        case NetworkAuthenticationRequired.statusCode: self = NetworkAuthenticationRequired

        default: self = Raw(statusCode: statusCode, reasonPhrase: reasonPhrase)
        }
    }

    var statusCode: Int {
        switch self {
        case .Continue:                      return 100
        case .SwitchingProtocols:            return 101
        case .Processing:                    return 102

        case .OK:                            return 200
        case .Created:                       return 201
        case .Accepted:                      return 202
        case .NonAuthoritativeInformation:   return 203
        case .NoContent:                     return 204
        case .ResetContent:                  return 205
        case .PartialContent:                return 206

        case .MultipleChoices:               return 300
        case .MovedPermanently:              return 301
        case .Found:                         return 302
        case .SeeOther:                      return 303
        case .NotModified:                   return 304
        case .UseProxy:                      return 305
        case .SwitchProxy:                   return 306
        case .TemporaryRedirect:             return 307
        case .PermanentRedirect:             return 308


        case .BadRequest:                    return 400
        case .Unauthorized:                  return 401
        case .PaymentRequired:               return 402
        case .Forbidden:                     return 403
        case .NotFound:                      return 404
        case .MethodNotAllowed:              return 405
        case .NotAcceptable:                 return 406
        case .ProxyAuthenticationRequired:   return 407
        case .RequestTimeout:                return 408
        case .Conflict:                      return 409
        case .Gone:                          return 410
        case .LengthRequired:                return 411
        case .PreconditionFailed:            return 412
        case .RequestEntityTooLarge:         return 413
        case .RequestURITooLong:             return 414
        case .UnsupportedMediaType:          return 415
        case .RequestedRangeNotSatisfiable:  return 416
        case .ExpectationFailed:             return 417
        case .ImATeapot:                     return 418
        case .AuthenticationTimeout:         return 419
        case .EnhanceYourCalm:               return 420
        case .UnprocessableEntity:           return 422
        case .Locked:                        return 423
        case .FailedDependency:              return 424
        case .PreconditionRequired:          return 428
        case .TooManyRequests:               return 429
        case .RequestHeaderFieldsTooLarge:   return 431

        case .InternalServerError:           return 500
        case .NotImplemented:                return 501
        case .BadGateway:                    return 502
        case .ServiceUnavailable:            return 503
        case .GatewayTimeout:                return 504
        case .HTTPVersionNotSupported:       return 505
        case .VariantAlsoNegotiates:         return 506
        case .InsufficientStorage:           return 507
        case .LoopDetected:                  return 508
        case .NotExtended:                   return 510
        case .NetworkAuthenticationRequired: return 511

        case .Raw(let statusCode, _):        return statusCode
        }
    }

    var reasonPhrase: String {
        switch self {
        case .Continue:                      return "Continue"
        case .SwitchingProtocols:            return "Switching Protocols"
        case .Processing:                    return "Processing"

        case .OK:                            return "OK"
        case .Created:                       return "Created"
        case .Accepted:                      return "Accepted"
        case .NonAuthoritativeInformation:   return "Non Authoritative Information"
        case .NoContent:                     return "No Content"
        case .ResetContent:                  return "Reset Content"
        case .PartialContent:                return "Partial Content"

        case .MultipleChoices:               return "Multiple Choices"
        case .MovedPermanently:              return "Moved Permanently"
        case .Found:                         return "Found"
        case .SeeOther:                      return "See Other"
        case .NotModified:                   return "Not Modified"
        case .UseProxy:                      return "Use Proxy"
        case .SwitchProxy:                   return "Switch Proxy"
        case .TemporaryRedirect:             return "Temporary Redirect"
        case .PermanentRedirect:             return "Permanent Redirect"

        case .BadRequest:                    return "Bad Request"
        case .Unauthorized:                  return "Unauthorized"
        case .PaymentRequired:               return "Payment Required"
        case .Forbidden:                     return "Forbidden"
        case .NotFound:                      return "Not Found"
        case .MethodNotAllowed:              return "Method Not Allowed"
        case .NotAcceptable:                 return "Not Acceptable"
        case .ProxyAuthenticationRequired:   return "Proxy Authentication Required"
        case .RequestTimeout:                return "Request Timeout"
        case .Conflict:                      return "Conflict"
        case .Gone:                          return "Gone"
        case .LengthRequired:                return "Length Required"
        case .PreconditionFailed:            return "Precondition Failed"
        case .RequestEntityTooLarge:         return "Request Entity Too Large"
        case .RequestURITooLong:             return "Request URI Too Long"
        case .UnsupportedMediaType:          return "Unsupported Media Type"
        case .RequestedRangeNotSatisfiable:  return "Requested Range Not Satisfiable"
        case .ExpectationFailed:             return "Expectation Failed"
        case .ImATeapot:                     return "I'm A Teapot"
        case .AuthenticationTimeout:         return "Authentication Timeout"
        case .EnhanceYourCalm:               return "Enhance Your Calm"
        case .UnprocessableEntity:           return "Unprocessable Entity"
        case .Locked:                        return "Locked"
        case .FailedDependency:              return "Failed Dependency"
        case .PreconditionRequired:          return "PreconditionR equired"
        case .TooManyRequests:               return "Too Many Requests"
        case .RequestHeaderFieldsTooLarge:   return "Request Header Fields Too Large"

        case .InternalServerError:           return "Internal Server Error"
        case .NotImplemented:                return "Not Implemented"
        case .BadGateway:                    return "Bad Gateway"
        case .ServiceUnavailable:            return "Service Unavailable"
        case .GatewayTimeout:                return "Gateway Timeout"
        case .HTTPVersionNotSupported:       return "HTTP Version Not Supported"
        case .VariantAlsoNegotiates:         return "Variant Also Negotiates"
        case .InsufficientStorage:           return "Insufficient Storage"
        case .LoopDetected:                  return "Loop Detected"
        case .NotExtended:                   return "Not Extended"
        case .NetworkAuthenticationRequired: return "Network Authentication Required"

        case .Raw(_, let reasonPhrase):      return reasonPhrase
        }
    }
}

public func ==(lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
    return lhs.statusCode == rhs.statusCode
}
