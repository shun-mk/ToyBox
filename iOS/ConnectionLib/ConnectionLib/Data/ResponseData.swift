//
//  ResponseData.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

open class ResponseData {

    /** ステータス */
    var status: ResponseStatus?
    /** メッセージ */
    var message: String?
    /** リクエストヘッダー */
    var header: [String: String]?
    /** リクエストURL */
    var requestUrl: String?
    /** 総データ量 */
    var totalBytes: Int?
    /** 通信済みデータ量 */
    var loadedBytes: Int?
    /** データ */
    var data: Data?
    /** データ文字列 */
    var dataString: String?
    /** エラー */
    var error: Error?
}
