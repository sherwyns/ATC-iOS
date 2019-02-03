//
//  EntityProtocol.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation

protocol EntityProtocol {
    var entityViewController: EntityViewController? {get set}
}

enum PayLoadType {
    case Favorite
}

protocol ATCOperationPayLoad {
    var payloadType : PayLoadType {get set}
    var payloadData: Any {get set}
}

class OperationPayload: NSObject, ATCOperationPayLoad {
    var payloadType: PayLoadType
    var payloadData: Any
    
    init(payloadType: PayLoadType, payloadData: Any) {
        self.payloadType = payloadType
        self.payloadData = payloadData
    }
}

protocol FavoriteProtocol {
    var operationPayload: OperationPayload? {get set}
}
