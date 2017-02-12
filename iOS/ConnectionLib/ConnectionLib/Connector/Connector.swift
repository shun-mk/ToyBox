//
//  Connector.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

protocol Connector {
    
    /**
     リクエスト実行
     */
    func exeRequest()
    
    /**
     QueueType取得
     
     - returns: QueueType
     */
    func getQueueType()
    
    /**
     リクエスト元オブジェクト
     
     - returns: リクエスト元オブジェクト
     */
    func exeReqSrc() -> AnyObject?
    
}
