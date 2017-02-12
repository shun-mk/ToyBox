//
//  Connector.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

protocol Connector {
    
    func exeRequest()
    
    func getQueueType()
    
    func exeReqSrc() -> AnyObject?
    
}
