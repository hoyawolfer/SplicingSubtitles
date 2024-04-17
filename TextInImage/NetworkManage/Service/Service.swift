//
//  Service.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import Moya
import Network
import HandyJSON

struct Service {
    
    /// get请求
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - parameters: <#parameters description#>
    ///   - model: <#model description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    @discardableResult
    public static func get<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                         completion: ((_ returnData: T?) -> Void)?) -> Cancellable {
        let network = Networking<RequestApi>()
        
        return network.request(.get(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
    
    @discardableResult
    public static func getbaidubce<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                         completion: ((_ returnData: T?) -> Void)?) -> Cancellable {
        let network = Networking<RequestApi>()
        
        return network.request(.getbaidubce(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
    /// post请求
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - parameters: <#parameters description#>
    ///   - model: <#model description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    @discardableResult
    public static func post<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                         completion: ((_ returnData: T?) -> Void)?) -> Cancellable {
        
        let network = Networking<RequestApi>()
        
        return network.request(.post(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
    
    @discardableResult
    public static func postbaidubce<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                         completion: ((_ returnData: T?) -> Void)?) -> Cancellable {
        
        let network = Networking<RequestApi>()
        
        return network.request(.postbaidubce(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
    
    /// post请求
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - parameters: <#parameters description#>
    ///   - model: <#model description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    @discardableResult
    public static func reportPost<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                         completion: ((_ returnData: T?) -> Void)?) -> Cancellable {
        
        let network = Networking<RequestApi>()
        
        return network.request(.reportPost(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
    /// post请求
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - parameters: <#parameters description#>
    ///   - model: <#model description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    @discardableResult
    public static func signGet<T: HandyJSON>(_ url: String,
                                         parameters: [String : Any]? = nil,
                                         model: T.Type,
                                        completion: ((_ returnData: T?) -> Void)?) -> Cancellable {

        let network = Networking<RequestApi>()
        
        return network.request(.signGet(url, parameters: parameters),
                               callbackQueue: DispatchQueue.main) { (result) in
            guard let completion = completion else { return }
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(nil)
                return
            }
            completion(returnData)
        }
    }
}
