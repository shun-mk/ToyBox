//
//  QueueOperationType.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

public enum QueueOperationType: Int {
    case `continue` = 0
    case stop
    case clear
    case allClear
}
