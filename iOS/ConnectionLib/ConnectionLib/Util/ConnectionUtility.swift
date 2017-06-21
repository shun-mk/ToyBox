//
//  ConnectionUtility.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/13.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

class ConnectionUtility {
    
    /**
     ネットワーク確認
     
     - returns: true 接続有り
     */
    class func isNetWorkStatus() -> Bool {
        let reachability: Reachability = Reachability.forInternetConnection()
        let status: NetworkStatus = reachability.currentReachabilityStatus()
        
        switch status {
        case NotReachable:
            
        default:
            <#code#>
        }
    }
}
