//
//  ResponseModel.swift
//  SuperBoss2020
//
//  Created by 李亚 on 2021/6/17.
//

import HandyJSON


struct ResponseModel<T: HandyJSON>: HandyJSON {
    var status: Int = 0
    var msg: String?
    var data: T?
    
    var isOK: Bool {
        get {
            return status == 10000000
        }
    }
}
