//
//  HttpConnector.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/24.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

public class HttpConnector: AbstractConnector {
    
    public init() {}
    
    // =============================================================================
    // MARK: - Request
    
    /**
     リクエスト実行
     
     - parameter responseFinishCallback:
     */
    open func exeRequest() {
        
        if CommonUtils.isNetWorkStatus() {
            
            let sessionConfig = URLSessionConfiguration.default
            if let milli = self.connectTimeoutMillies {
                sessionConfig.timeoutIntervalForRequest = TimeInterval(milli)
            }
            if let milli = self.readTimeoutMillies {
                sessionConfig.timeoutIntervalForResource = TimeInterval(milli)
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            URLSession(configuration: sessionConfig).dataTask(with: self.genRequest(), completionHandler: { (data, response, error) -> () in
                
                
                self.response(data, response: response, error: error)
                
                semaphore.signal()
            }) .resume()
            semaphore.wait(timeout: DispatchTime.distantFuture)
        } else {
            
            // TODO: ResponseDataを生成してメンバ変数に格納
            
        }
    }
    
    /**
     リクエストインスタンス生成
     
     - returns: リクエストインスタンス
     */
    func genRequest() -> NSMutableURLRequest {
        
        var data: NSMutableData?
        var contentType = "application/x-www-form-urlencoded"
        
        if self.method == .get {
            
            self.url = self.url! + "?" + self.createKeyValStringParam(self.param as? [String: String], isEncode: false)
            
        } else {
            
            if let image = self.image {
                
                if data == nil {
                    data = NSMutableData()
                }
                
                let uniqueId = ProcessInfo.processInfo.globallyUniqueString
                let boundary = "---------------------------\(uniqueId)"
                
                contentType = "multipart/form-data; boundary=\(boundary)"
                
                if let param = self.param {
                    data?.append(self.getParamToDataForMultipart(param as AnyObject?, boundary: boundary) as Data)
                }
                
                // TODO: ファイル名が固定となっている
                // 画像データ
                let headerData = "--\(boundary)\r\nContent-Disposition: form-data; name=\"image\"; filename=\"profile_image.png\"\r\nContent-Type: image/png\r\n\r\n"
                data?.append(headerData.data(using: String.Encoding.utf8)!)
                data?.append(NSData(data: UIImagePNGRepresentation(image)!) as Data)
                let footerData = "\r\n\r\n--\(boundary)--\r\n"
                data?.append(footerData.data(using: String.Encoding.utf8)!)
                
                
            } else if let param = self.param {
                
                if data == nil {
                    data = NSMutableData()
                }
                
                contentType = self.isConvReqParamToJson ? "application/json" : "application/x-www-form-urlencoded"
                
                let param: String? = self.isConvReqParamToJson ? self.createJsonStringParam(param as AnyObject) : self.createKeyValStringParam(param as? [String: String])
                data?.append(param!.data(using: String.Encoding.utf8)!)
            }
        }
        
        let encodeUrl = self.url!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Log.debugLog("after encode: " + encodeUrl!)
        
        let url = URL(string: encodeUrl!)!
        let req = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeInterval(self.connectTimeoutMillies ?? 10))
        
        // User-Agent
        if let userAgent = self.userAgent {
            req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        // Content-type
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Basic Autentication
        if let userName = self.basicAuthUserName {
            
            let userAndPass = userName + ":" + (self.basicAuthPassword ?? "")
            let userAndPassEncoding = userAndPass.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            req.setValue("Basic " + userAndPassEncoding!, forHTTPHeaderField: "Authorization")
        }
        
        // Cookie
        if let cookie = self.cookie {
            
            // TODO:
            //            req.setValue("\(self.kSessionIdKey)=\(sessionId)", forHTTPHeaderField: "Cookie")
        }
        
        req.httpMethod = method.rawValue
        req.httpBody = data as Data?
        
        return req
    }
    
    /**
     Key:Value形式のパラメータ文字列を生成
     
     - parameter params:   パラメータ
     - parameter isEncode: エンコードフラグ
     
     - returns: パラメータ文字列
     */
    open func createKeyValStringParam(_ params: [String: String]?, isEncode: Bool = true) -> String {
        var paramStr: String = ""
        
        if let _params = params {
            for (var key, var val) in _params {
                
                if isEncode {
                    key = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
                    val = val.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
                }
                
                paramStr += key + "=" + val + "&"
            }
            let length: Int = paramStr.characters.count
            if length > 0 {
                paramStr = (paramStr as NSString).substring(to: length - 1)
            }
        }
        return paramStr
    }
    
    /**
     Multipart用のパラメータを生成
     
     - parameter params:    パラメータ
     - parameter parentKey: 親Key
     - parameter boundary:  boundary
     
     - returns: Multipart用のパラメータ
     */
    fileprivate func getParamToDataForMultipart(_ params: AnyObject?, parentKey: String? = nil, boundary: String) -> NSMutableData {
        
        let data = NSMutableData()
        if let _params = params as? [String: AnyObject] {
            
            for (key, val) in _params {
                
                var nextKey = ""
                if let _parentKey = parentKey {
                    nextKey = "\(_parentKey)[\(key)]"
                } else {
                    nextKey = key
                }
                
                if let _val = val as? String {
                    
                    data.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(nextKey)\" \r\n\r\n\(_val)\r\n".data(using: String.Encoding.utf8)!)
                } else {
                    data.append(self.getParamToDataForMultipart(val, parentKey: nextKey, boundary: boundary) as Data)
                }
            }
        } else if let _params = params as? [AnyObject] {
            
            for (i, val) in _params.enumerated() {
                
                var nextKey = ""
                if let _parentKey = parentKey {
                    nextKey = "\(_parentKey)[\(i.description)]"
                } else {
                    nextKey = i.description
                }
                
                if let _val = val as? String {
                    
                    data.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(nextKey)\" \r\n\r\n\(_val)\r\n".data(using: String.Encoding.utf8)!)
                } else {
                    data.append(self.getParamToDataForMultipart(val, parentKey: nextKey, boundary: boundary) as Data)
                }
            }
        }
        
        return data
    }
    
    /**
     Jsonに変換したパラメータ文字列を生成
     
     - parameter params: パラメータ
     
     - returns: Json文字列
     */
    fileprivate func createJsonStringParam(_ params: AnyObject) -> String? {
        
        let theJSONData = try! JSONSerialization.data(
            withJSONObject: params ,
            options: JSONSerialization.WritingOptions(rawValue: 0))
        return NSString(data: theJSONData, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    /**
     <#Description#>
     
     - parameter responseCallback: <#responseCallback description#>
     */
    open func get(_ responseCallback: ((_ data: HttpResponseData) -> QueueOperationType)) {
        self.method = .Get
        self.request(responseCallback)
    }
    
    /**
     <#Description#>
     
     - parameter responseCallback: <#responseCallback description#>
     */
    open func post(_ responseCallback: ((_ data: HttpResponseData) -> QueueOperationType)) {
        self.method = .Post
        self.request(responseCallback)
    }
    
    /**
     <#Description#>
     
     - parameter responseCallback: <#responseCallback description#>
     */
    open func put(_ responseCallback: ((_ data: HttpResponseData) -> QueueOperationType)) {
        self.method = .Put
        self.request(responseCallback)
    }
    
    /**
     <#Description#>
     
     - parameter responseCallback: <#responseCallback description#>
     */
    open func delete(_ responseCallback: ((_ data: HttpResponseData) -> QueueOperationType)) {
        self.method = .Delete
        self.request(responseCallback)
    }
    
    // =============================================================================
    // MARK: - Response
    
    /**
     <#Description#>
     
     - parameter response: <#response description#>
     
     - returns: <#return value description#>
     */
    
    /**
     レスポンス処理
     
     - parameter data:     取得データ
     - parameter response: レスポンス
     - parameter error:    Error
     
     - returns: <#return value description#>
     */
    func response(_ data: Data?, response: URLResponse?, error: NSError?) {
        
        let data = HttpResponseData(data: data, response: response, error: error, responseDataType: self.responseDataType)
        data.reqUrl = self.url
        
        self.responseData = data
    }
    
    open func exeResponseCallback() -> QueueOperationType {
        return self.responseCallback!(self.responseData!)
    }
    
    
    // =============================================================================
    // MARK: - Request Parameter Set Part
    
    
    /**
     呼び出し元オブジェクト参照の設定
     
     - parameter srcObj: 呼び出し元オブジェクト
     
     - returns: HttpConnector
     */
    open func setReqSrc(_ reqSrc: AnyObject) -> Self {
        self.reqSrc = reqSrc
        return self
    }
    
    /**
     リクエストヘッダーの設定
     
     - parameter header: リクエストヘッダー
     
     - returns: HttpConnector
     */
    open func setHeader(_ header: [String: String]) -> Self {
        self.header = header
        return self
    }
    
    /**
     リクエストヘッダーの追加
     
     - parameter key: Key
     - parameter val: Val
     
     - returns: HttpConnector
     */
    open func addHeader(_ key: String, val: String) -> Self {
        self.header?[key] = val
        return self
    }
    
    /**
     リクエストパラメータの設定
     
     - parameter param: リクエストパラメータ
     
     - returns: HttpConnector
     */
    open func setParam(_ param: [String: AnyObject]) -> Self {
        self.param = param
        return self
    }
    
    /**
     リクエストパラメータの追加
     
     - parameter key: Key
     - parameter val: Val
     
     - returns: HttpConnector
     */
    open func addParam(_ key: String, val: String) -> Self {
        self.param?[key] = val as AnyObject?
        return self
    }
    
    /**
     データを設定
     
     - parameter data: データ
     
     - returns: HttpConnector
     */
    open func setUploadData(_ data: Data) -> Self {
        self.data = data
        return self
    }
    
    /**
     画像データを設定
     
     - parameter image: 画像データ
     
     - returns: HttpConnector
     */
    open func setUploadImage(_ image: UIImage) -> Self {
        self.image = image
        return self
    }
    
    /**
     ファイルを設定
     
     - parameter file: ファイル
     
     - returns: HttpConnector
     */
    open func setUploadFile(_ file: FILE) -> Self {
        self.file = file
        return self
    }
    
    /**
     Cookieを設定
     
     - parameter cookie: Cookie
     
     - returns: HttpConnector
     */
    open func setCookie(_ cookie: [String: String]) -> Self {
        self.cookie = cookie
        return self
    }
    
    /**
     Cookieを追加
     
     - parameter key: Key
     - parameter val: Val
     
     - returns: HttpConnector
     */
    open func addCookie(_ key: String, val: String) -> Self {
        self.cookie?[key] = val
        return self
    }
    
    /**
     タイムアウト時間(ミリ秒)を設定
     
     - parameter millies: タイムアウト時間
     
     - returns: HttpConnector
     */
    open func setTimeout(_ millies: Int) -> Self {
        self.readTimeoutMillies = millies
        self.connectTimeoutMillies = millies
        return self
    }
    
    /**
     タイムアウト時間(ミリ秒)を設定
     
     - parameter reqMillies: 読み込みタイムアウト時間
     - parameter conMillies: 接続タイムアウト時間
     
     - returns: HttpConnector
     */
    open func setTimeout(_ readMillies: Int, conMillies: Int) -> Self {
        self.readTimeoutMillies = readMillies
        self.connectTimeoutMillies = conMillies
        return self
    }
    
    /**
     QueueTypeの設定
     
     - parameter type: QueueType
     
     - returns: HttpConnector
     */
    open func setQueueType(_ type: QueueType) -> Self {
        self.queueType = type
        return self
    }
    
    /**
     ResponseDataTypeの設定
     
     - parameter type: ResponseDataType
     
     - returns: HttpConnector
     */
    open func setResponseDataType(_ type: ResponseDataType...) -> Self {
        self.responseDataType = type
        return self
    }
    
    /**
     UserAgentの設定
     
     - parameter userAgent: UserAgent
     
     - returns: HttpConnector
     */
    open func setUserAgent(_ userAgent: String) -> Self {
        self.userAgent = userAgent
        return self
    }
    
    /**
     Basic認証のパラメータを設定
     
     - parameter userName: ユーザ名
     - parameter password: パスワード
     
     - returns: HttpConnector
     */
    open func setBasicAuth(_ userName: String, password: String) -> Self {
        self.basicAuthUserName = userName
        self.basicAuthPassword = password
        return self
    }
    
    /**
     リクエストパラメータJson変換フラグの設定
     
     - parameter flg: リクエストパラメータJson変換フラグ
     
     - returns: HttpConnector
     */
    open func setConvReqParamToJson(_ flg: Bool) -> Self {
        self.isConvReqParamToJson = flg
        return self
    }
    
    /**
     URLの設定
     
     - parameter url: URL
     
     - returns: HttpConnector
     */
    open func setUrl(_ url: String) -> Self {
        self.url = url
        return self
    }
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    
    // =============================================================================
    // MARK: - Property
    
    /** リクエストヘッダー */
    var header: [String: String]?
    /** リクエストパラメータ */
    var param: [String: AnyObject]?
    /** Url文字列 */
    var url: String?
    /** HTTPリクエストメソッド */
    var method: Method = .get
    /** バイナリ */
    var data: Data?
    /** 画像データ */
    var image: UIImage?
    /** ファイル */
    var file: FILE?
    /** Cookie */
    var cookie: [String: String]?
    /** 読み込み中通信タイムアウト設定時間 */
    var readTimeoutMillies: Int?
    /** 接続中通信タイムアウト設定時間 */
    var connectTimeoutMillies: Int?
    /** キュータイプ */
    open var queueType: QueueType? = .serial
    /** Basic認証:ユーザ名 */
    var basicAuthUserName: String?
    /** Basic認証:パスワード */
    var basicAuthPassword: String?
    /** 呼び出し元オブジェクト参照 */
    open weak var reqSrc: AnyObject?
    /** レスポンスデータタイプ */
    var responseDataType: [ResponseDataType] = [.normal]
    /** UserAgent */
    var userAgent: String?
    /** リクエストパラメータJson変換フラグ */
    var isConvReqParamToJson = false
    /** レスポンスデータコールバック */
    open var responseCallback: ((_ data: HttpResponseData) -> QueueOperationType)?
    /** レスポンスデータ */
    open var responseData: HttpResponseData?
}
