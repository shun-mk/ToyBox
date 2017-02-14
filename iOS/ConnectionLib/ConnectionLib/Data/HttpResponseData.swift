//
//  HttpResponseData.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/12.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

open class HttpResponseData: ResponseData {
    
    // MARK: - 初期処理
    
    init(data: Data?, response: URLResponse?, error: Error?, responseDataType: [ResponseDataType]) {
        super.init()
        self.setResponseData(data, response: response, error: error, responseDataType: responseDataType)
    }
    
    // MARK: - function
    
    func setResponseData(_ data: Data?, response: URLResponse?, error: Error?, responseDataType: [ResponseDataType]) {
        
        if let error = error {
            self.setResponseError(error)
        } else {
            self.setResponseResult(response, data: data, responseDataType: responseDataType)
        }
        switch self.status {
        case .some(.success):
            self.success()
        case .some(.networkError):
            self.networkError()
        case .some(.httpStatusCodeError):
            self.httpStatusCodeError()
        case .some(.timeout):
            self.timeout()
        case .some(.parseError):
            self.parseError()
        default:
            // otherErrorとnilは同義で扱っている
            self.otherError()
        }
    }
    
    fileprivate func setResponseResult(_ response: URLResponse?, data: Data?, responseDataType: [ResponseDataType]) {
        
        let httpResponse = response as? HTTPURLResponse
        self.httpStatusCode = httpResponse?.statusCode
        
        switch self.httpStatusCode {
        case 200?, 304?:
            self.status = .success
            
            self.setCookie(httpResponse)
            let headerFields = httpResponse?.allHeaderFields as? [String: String]
            self.lastModified = headerFields?["Last-Modified"]
        default:
            self.status = .httpStatusCodeError
        }
        
    }
    
    fileprivate func setResponseError(_ error: Error) {
        
        self.status = (error as NSError).code == Int(CFNetworkErrors.cfurlErrorTimedOut.rawValue) ? .timeout : .otherError
        self.error = error
    }
    
    /**
     Cookieの設定
     
     - parameter response: レスポンス
     */
    func setCookie(_ response: HTTPURLResponse?) {
        guard let headerFields = response?.allHeaderFields as? [String: String] else { return }
        guard let responseUrl = response?.url else { return }
        
        let cookiesFields = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: responseUrl)
        let cookies: [String: String] = cookiesFields.reduce([:]) {
            var dict = $0
            dict[$1.name] = $1.value
            return dict
        }
        self.cookies = cookies
    }
    
    /**
     成功時
     */
    func success() {}
    
    /**
     通信エラー時
     */
    func networkError() {}
    
    /**
     Httpステータスエラー時
     */
    func httpStatusCodeError() {}
    
    /**
     タイムアウト時
     */
    func timeout() {}
    
    /**
     パースエラー時
     */
    func parseError() {}
    
    /**
     その他エラー時
     */
    func otherError() {}
    
    // MARK: - Request Parameter Set Part
    
    /** HTTPステータスコード */
    var httpStatusCode: Int?
    /** Json */
    var json: [String: Any]?
    /** Image */
    var image: UIImage?
    /** Cookie */
    var cookies: [String: String]?
    /** Last-Modified */
    var lastModified: String?
    
}
