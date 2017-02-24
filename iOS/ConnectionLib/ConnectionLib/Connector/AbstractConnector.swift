//
//  AbstractConnector.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/24.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

protocol AbstractConnector: class, Connector {
    
    associatedtype T: ResponseData
    
    var queueType: QueueType { get set }
    
    var responseCallback: ((_ data: T) -> QueueOperationType)? { get set }
    
    var responseData: T? { get set }
    
    weak var reqSrc: AnyObject? { get set }
    
}

extension AbstractConnector {
    
    public func reuqest(_ calback: @escaping ((_ data: T) -> QueueOperationType)) {
        
        self.responseCallback = calback
        self.responseData = nil
        QueueManager.instance.add(self)
    }
    
    public func getQueueType() -> QueueType {
        return self.queueType
    }
    
    public func setQueueType(_ queueType: QueueType) {
        self.queueType = queueType
    }
    
    /**
     リクエスト元オブジェクト
     
     - returns: リクエスト元オブジェクト
     */
    public func getReqSrc() -> AnyObject? {
        return self.reqSrc
    }
}
