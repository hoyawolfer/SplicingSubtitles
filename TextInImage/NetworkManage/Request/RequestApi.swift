//
//  RequestApi.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import Moya


enum RequestApi {
    case get(String, parameters: [String: Any]?)
    case post(String, parameters: [String: Any]?)
    case getbaidubce(String, parameters: [String: Any]?)
    case postbaidubce(String, parameters: [String: Any]?)
    case reportPost(String, parameters: [String: Any]?)
    case signGet(String, parameters: [String: Any]?)
}

extension RequestApi: RequestTargetType {
    var headers: [String : String]? {
        return setupHeaders(["Content-Type":"application/x-www-form-urlencoded"])
    }
    
    
    
    var baseURL: URL {
        switch self {
        case .reportPost(_, _):
            return setupBaseUrl("")
        case .signGet(_, _):
            return setupBaseUrl("https://api.fanyi.baidu.com")
        case .getbaidubce(_, _), .postbaidubce(_, _):
            return setupBaseUrl("https://aip.baidubce.com")
        default:
            return setupBaseUrl("https://api.fanyi.baidu.com")
        }
    }
    
    var path: String {
        switch self {
        case .get(let url, _), .signGet(let url, _), .getbaidubce(let url, _):
            return setupPath(url)
        case .post(let url, _), .reportPost(let url, _), .postbaidubce(let url, _):
            return setupPath(url)
        }
    }
        
    var method: NetHTTPMethod {
        switch self {
        case .get(_ , _), .signGet(_ , _), .getbaidubce(_, _):
            return setupMethod(.get)
        case .post(_ , _), .reportPost(_ , _), .postbaidubce(_, _):
            return setupMethod(.post)
        }
    }
    
    var parameters: [String: Any]? {
        var params: [String: Any]?
        switch self {
        case .get(_, let parameters), .signGet(_, let parameters), .getbaidubce(_, let parameters):
            params = parameters?.filter({ (key, value) in
                if let val = value as? String, val == "" {
                    return false
                }
                return true
            })
        case .post(_, let parameters), .reportPost(_, let parameters), .postbaidubce(_, let parameters):
            params = parameters
        }
        return setupParameters(params)

    }
}
