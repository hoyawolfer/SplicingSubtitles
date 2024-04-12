//
//  NetworkManage.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/15.
//

import Foundation
import Moya


public let activityPlugin = NetworkActivityPlugin { (state, targetType) in
    switch state {
    case .began:
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    case .ended:
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

public typealias NetHTTPMethod = Moya.Method
public typealias NetValidationType = Moya.ValidationType
//  测试用的
public typealias NetSampleResponse = Moya.EndpointSampleResponse
//  测试用的
public typealias NetStubBehavior = Moya.StubBehavior
