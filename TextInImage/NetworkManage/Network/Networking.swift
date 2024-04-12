//
//  Networking.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//


import Foundation
import Moya
import Alamofire

public struct Networking<T: RequestTargetType> {
    public let provider: MoyaProvider<T>
    
    public init(provider: MoyaProvider<T> = newDefaultProvider()) {
        self.provider = provider
    }
}


extension Networking {

    @discardableResult
    public func request(_ target: T,
                        callbackQueue: DispatchQueue? = DispatchQueue.main,
                        progress: ProgressBlock? = .none,
                        completion: @escaping Completion) -> Cancellable {
        return self.provider.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
            completion(result)
        }
    }
    
}

extension Networking {
    
    public static func newDefaultProvider() -> MoyaProvider<T> {
        return MoyaProvider.init(endpointClosure: Networking<T>.endpointsClosure(),
                                  requestClosure: Networking<T>.endpointResolver(),
                                  stubClosure: Networking<T>.APIKeysBasedStubBehaviour,
                                  manager: newManager(),
                                  plugins: plugins)
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
            do {
                return defaultEndpoint
            } catch {
                return defaultEndpoint
            }
            
//            return defaultEndpoint;
        }
    }
    
    static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
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
    
    static func newManager(delegate: SessionDelegate = SessionDelegate(),
                    serverTrustPolicyManager: ServerTrustPolicyManager? = nil) -> Manager {
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let manager = Alamofire.SessionManager(configuration: configuration, delegate:delegate, serverTrustPolicyManager:serverTrustPolicyManager)
        manager.startRequestsImmediately = false
        return manager
    }
    
    static var plugins: [PluginType] {
        return [
            activityPlugin,
            NetworkLoginPlugin(),
            NetworkLoggerPlugin(),
        ]
    }
}





