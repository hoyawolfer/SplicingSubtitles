//
//  RequestTargetType.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import Moya
import Alamofire

public protocol RequestTargetType: TargetType {
    var parameters: [String: Any]? { get }
    var stubBehavior: NetStubBehavior { get }
    var sampleResponse: NetSampleResponse { get }
}

struct JSONArrayEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()

        guard let json = parameters?["jsonArray"] else {
            return request
        }

        let data = try JSONSerialization.data(withJSONObject: json, options: [])

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.httpBody = data

        return request
    }
}

extension RequestTargetType {
    public var base: String { return RequestService.shared.requestBaseUrl }
    
    public var baseURL: URL { return URL(string: base)! }
    
    public var headers: [String : Any]? { return RequestService.shared.requestHeaders }
    
    public var parameters: [String: Any]? { return RequestService.shared.requestParams }
        
    public var task: Task {
        let encoding: ParameterEncoding
        switch self.method {
        case .post:
            encoding = JSONEncoding.default
        default:
            encoding = URLEncoding.default
        }
        if var requestParameters = parameters {
            if let _ = requestParameters["jsonArray"] {
                return .requestParameters(parameters: requestParameters, encoding: JSONArrayEncoding.default)
            } else if let _ = requestParameters["postUrlParameter"] {
                requestParameters.removeValue(forKey: "postUrlParameter")
                return .requestCompositeParameters(bodyParameters: requestParameters, bodyEncoding: JSONEncoding.default, urlParameters: ["access_token": "24.348395bd809d2522f014b088d4a23c76.2592000.1715929207.282335-61888234"])
            } else {
                return .requestParameters(parameters: requestParameters, encoding: encoding)
            }
        }
        return .requestPlain
    }
    
    
    public var method: NetHTTPMethod {
        return .get
    }
    
    public var validationType: NetValidationType {
        return .successCodes
    }
    
    public var stubBehavior: StubBehavior {
        return .never
    }
    
    public var sampleData: Data {
        return "response: test data".data(using: String.Encoding.utf8)!
    }
    
    public var sampleResponse: NetSampleResponse {
        return .networkResponse(200, self.sampleData)
    }
    
    
    // MARK: - public func
    public func setupBaseUrl(_ baseUrl: String) -> URL {
        RequestService.shared.requestBaseUrl = baseUrl
        return URL(string: baseUrl)!
    }

    public func setupPath(_ path: String) -> String {
        RequestService.shared.requestUrl = path
        return path
    }

    public func setupMethod(_ method: NetHTTPMethod) -> NetHTTPMethod {
        RequestService.shared.requestMethod = method
        return method
    }

    public func setupParameters(_ params: [String: Any]?) -> [String: Any] {
        
        var newParameters = [String: Any]()
        if let tempParams = params {
            tempParams.forEach { (arg) in
                let (key, value) = arg
                newParameters[key] = value
            }
        }
        RequestService.shared.requestParams = newParameters
        return newParameters
    }
    
    public func setupHeaders(_ headers: [String: String]?) -> [String: String] {
        
        var newHeaders = [String: String]()
        if let tempHeaders = headers {
            tempHeaders.forEach { (arg) in
                let (key, value) = arg
                newHeaders[key] = value
            }
        }
        let sema = DispatchSemaphore(value: 1)
        sema.wait()
        RequestService.shared.requestHeaders = newHeaders
        sema.signal()

        return newHeaders
    }
}





