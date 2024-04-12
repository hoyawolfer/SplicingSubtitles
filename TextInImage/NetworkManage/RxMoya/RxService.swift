//
//  RxService.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/15.
//

import Foundation
import Moya
import Network
import HandyJSON

import enum Result.Result
import RxSwift


typealias MoyaResult = Result<Moya.Response, MoyaError>


struct RxService: RxNetworkingType {    
    typealias T = RequestApi
    static var current = RxService()
    
    fileprivate let disposeBag = DisposeBag()
    
    internal var provider = RxNetworking<RequestApi>()
    
    private init() {
        NetworkConfigure.replace(codeKey: "status", messageKey: "message", dataKey: "result", successKey: 200)
    }
}


extension RxService {
    @discardableResult
    func get<T: HandyJSON>(_ url: String, parameters: [String: Any]? = nil, model: T.Type) -> Single<T> {
        
        return Single<T>.create { (single) -> Disposable in
            
            provider.rx.req(.get(url, parameters: parameters))
                .asObservable()
                .subscribe(onNext: {
                    if let returnData = try? $0.value?.mapModel(T.self) {
                        single(.success(returnData))
                    }
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    
    @discardableResult
    func post<T: HandyJSON>(_ url: String, parameters: [String: Any]? = nil, model: T.Type) -> Single<T> {
        
        return Single<T>.create { (single) -> Disposable in
            provider.rx.req(.post(url, parameters: parameters))
                .asObservable()
                .subscribe(onNext: {
                    if let returnData = try? $0.value?.mapModel(T.self) {
                        single(.success(returnData))
                    }
                })
                .disposed(by: disposeBag)
            return Disposables.create { }
        }
    }
}
