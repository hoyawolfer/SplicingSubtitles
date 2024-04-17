//
//  NetworkLogPlugin.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/15.
//

import Foundation
import Moya
import enum Result.Result


/// 通用网络插件
final class NetworkLoggerPlugin: PluginType {
    /// 开始请求字典
    private static var startDates: [String: Date] = [:]
    
//    var startDate: Date = Date()
    
    /// 即将发送请求
    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        
        // @hyw edit 模拟器崩溃 偶先概率比较大
//        // 设置当前时间
//        NetworkLoggerPlugin.startDates["\(target)"] = Date()
//        startDate = Date()
        #endif
    }
    
    /// 收到请求时
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        #if DEBUG
        
//        guard let startDate = NetworkLoggerPlugin.startDates["\(target)"] else { return }
//        // 获取当前时间与开始时间差（秒数）
//        let requestDate = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
        
        print("🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽 请求日志 🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽")
        print("URL : \(target.baseURL)\(target.path)")
        print("请求方式：\(target.method.rawValue)")
//        print("请求时间 : \(String(format: "%.1f", requestDate))s")
        print("请求头：\(target.headers ?? [:])")
        if let request = result.value?.request {
            if target.method == .get {
                print("请求参数 : \(request.url?.absoluteString ?? "")")
            } else {
                if let requestBody = request.httpBody {
                    let decrypt = requestBody.parameterString()
//                    print("请求参数 : \(decrypt)")
                }
            }
        }
        
        switch result {
        case let .success(response):
            print("请求成功：\(response)")
            
        case let .failure(error):
            print("请求错误：\(error)")
        }
        print("🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼")
        
        // 删除完成的请求开始时间
//        objc_sync_enter(self)
//        NetworkLoggerPlugin.startDates.removeValue(forKey: "\(target)")
//        objc_sync_exit(self)

        #endif
    }
}


fileprivate extension Data {
    func parameterString() -> String {
        guard let json = try? JSONSerialization.jsonObject(with: self),
            let value = json as? [String : Any] else {
            return ""
        }
        return "\(value)"
    }
    
}
