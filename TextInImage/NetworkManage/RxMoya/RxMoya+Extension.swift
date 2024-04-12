//
//  RxMoya+Extension.swift
//  NetworkTest
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import RxSwift
import Moya

extension Reactive where Base: MoyaProviderType {

    @discardableResult
    func req(_ target: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<MoyaResult> {
        return Single<MoyaResult>.create { [weak base] (single) -> Disposable in
            let cancellableToken = base?.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                single(.success(result))
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
