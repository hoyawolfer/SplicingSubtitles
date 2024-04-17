//
//  NormalRequest.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/9/17.
//

import UIKit
import Alamofire
import HandyJSON

class NormalRequest: NSObject {
    
    let timestamp = String(Date().timeIntervalSince1970)
    
    private func setupHeadrs() -> HTTPHeaders? {
        return ["application/x-www-form-urlencoded": "Content-Type"]
    }
    
    
    /// 网络请求 get/post
    func request<T: HandyJSON>(host: String, path:String, method: HTTPMethod, parameters: Parameters? = nil, header: Parameters? = nil, model: T.Type, succ: @escaping (_ resp: T?) -> Void, fail: @escaping (_ err: Any)->()) {

        let requestUrl = host + path
        var headers = setupHeadrs()
        
        /// 参数编码
        var encoding: ParameterEncoding = URLEncoding.default
        if (method == .post) {
            encoding = JSONEncoding.default
        }
        Alamofire.request(requestUrl, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            
            if response.result.isSuccess {
                
                let jsonString = String(data: response.data ?? Data(), encoding: .utf8)
                if let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) {
                    succ(model)
                }
                
                print("🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽 普通请求日志 🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽🔽")
                print("网络请求url：\(response.request?.url?.absoluteString ?? "")")
                print("网络请求method：\(String(describing: response.request?.httpMethod))")
                print("网络请求header：\(String(describing: response.request?.allHTTPHeaderFields))")
                print("网络请求参数：\(String(describing: response.request?.httpBody))")
                print("网络请求回参：" + (jsonString ?? ""))
                print("🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼🔼")
            }
            else {
                fail(response.error!)
            }
        }
    }
}
