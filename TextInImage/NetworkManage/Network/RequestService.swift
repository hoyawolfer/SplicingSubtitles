//
//  WebService.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import Alamofire
import Moya


class RequestService: NSObject {
    
    /// base URL
    open var requestBaseUrl: String = ""
    /// 请求方式  default = get
    open var requestMethod: NetHTTPMethod = .get
    /// 请求链接
    open var requestUrl: String = ""
    /// 请求参数
    open var requestParams: [String: Any]? = [:]
    /// 请求头
    open var requestHeaders: [String: Any]? = [:]
    /// 请求超时时间
    open var timeoutIntervalForRequest: Double = 70.0

    
    // MARK: - 单例
    static let shared = RequestService()
    
    // Make sure the class has only one instance
    // Should not init or copy outside
    private override init() {}
    
    override func copy() -> Any {
        return self // NetworkManage.shared
    }
    
    override func mutableCopy() -> Any {
        return self // NetworkManage.shared
    }
}
