//
//  RxNetworking.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/15.
//

import Foundation
import Moya
import Alamofire

protocol RxNetworkingType {
    associatedtype T: RequestTargetType
    var provider: RxNetworking<T> { get }
}

/// 映射
class RxNetworking<Target: RequestTargetType>: MoyaProvider<Target> {
    
    convenience init(plugins: [PluginType]) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        self.init(configuration: configuration, plugins: plugins)
    }
    
    init(configuration: URLSessionConfiguration = .default, plugins: [PluginType] = []) {
        
        var newPlugins = plugins
        
        newPlugins += [
            activityPlugin,
            NetworkLoggerPlugin(),
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        
        super.init(endpointClosure: RxNetworking<Target>.endpointsClosure(),
                   requestClosure: RxNetworking<Target>.endpointResolver(),
                   stubClosure: RxNetworking<Target>.APIKeysBasedStubBehaviour,
                   manager: manager,
                   plugins: newPlugins)
    }
    
    static func endpointsClosure<T>() -> (T) -> Endpoint where T: RequestTargetType {
        return { target in
            let defaultEndpoint = Endpoint(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: { target.sampleResponse },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
            return defaultEndpoint;
        }
    }
    
    static func endpointResolver() -> MoyaProvider<Target>.RequestClosure {
        return { (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                request.httpShouldHandleCookies = false
                request.timeoutInterval = RequestService.shared.timeoutIntervalForRequest
                closure(.success(request))
            } catch let error {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
    
    static func APIKeysBasedStubBehaviour<T>(_ target: T) -> Moya.StubBehavior where T: RequestTargetType {
        return target.stubBehavior;
    }
}
