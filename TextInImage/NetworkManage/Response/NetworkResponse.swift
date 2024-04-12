//
//  NetworkResponse.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/10.
//

import Foundation
import Moya

func handleResponse(_ response: Moya.Response) throws -> Any {
    do {
        let json = try response.mapJSON()
        return json
    }
    catch (let error as Moya.MoyaError) {
        throw NetworkError.init(error: error)
    }
    catch {
        throw NetworkError.underlying(NSError(domain: "UnderlyingDomain", code: 200, userInfo: nil), nil)
    }
}
