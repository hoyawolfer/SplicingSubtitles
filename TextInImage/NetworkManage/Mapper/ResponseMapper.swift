//
//  ResponseMapper.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/17.
//

import Moya
import HandyJSON


extension Array: HandyJSON{}
extension String: HandyJSON{}
extension Dictionary: HandyJSON{}
extension NSNull: HandyJSON{}
extension Bool: HandyJSON{}
extension Int: HandyJSON{}

//MARK: 请求结果模型解析

extension Moya.Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) throws -> T {
        let jsonString = String(data: data, encoding: .utf8)
        guard let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            throw MoyaError.jsonMapping(self)
        }
        return model
    }
}
