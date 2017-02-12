//
//  ResponseStatus.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

public enum ResponseStatus: Int {
    case success = 0
    case networkError
    case timeout
    case httpStatusCodeError
    case parseError
    case otherError
}
