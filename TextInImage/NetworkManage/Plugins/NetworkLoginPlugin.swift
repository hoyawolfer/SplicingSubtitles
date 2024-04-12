//
//  NetworkLoginPlugin.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/12/23.
//

import Foundation
import Moya
import enum Result.Result

class NetworkLoginPlugin: PluginType {
    /// 收到请求时
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        
    }
}
