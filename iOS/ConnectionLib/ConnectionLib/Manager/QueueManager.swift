//
//  QueueManager.swift
//  ConnectionLib
//
//  Created by Shunsaku Miki on 2017/02/13.
//  Copyright © 2017年 Shunsaku Miki. All rights reserved.
//

import Foundation

class QueueManager {
    
    // MARK: - function
    
    /**
     Queueからconnectorオブジェクトを削除する
     
     - parameter connector: <#connector description#>
     */
    func clear(_ connector: Connector) {
        self.semaphore.wait()
        defer {
            self.semaphore.signal()
        }
        if connector.getQueueType() == .parallel {
            self.parallelQueue.remove(connector)
        } else {
            self.serialQueue.remove(connector)
        }
    }
    
    /**
     Queueのオブジェクトのすべて削除する
     */
    func clearAll() {
        self.semaphore.wait()
        defer {
            self.semaphore.signal()
        }
        self.serialQueue.removeAllObjects()
        self.parallelQueue.removeAllObjects()
    }
    
    /**
     直列通信のためのQueueのオブジェクトをすべて削除する
     */
    func clearSerialQueue() {
        self.semaphore.wait()
        defer {
            self.semaphore.signal()
        }
        self.serialQueue.removeAllObjects()
    }
    
    /**
     並列通信のためのQueueオブジェクトをすべて削除する
     */
    func clearParallelQueue() {
        self.semaphore.wait()
        defer {
            self.semaphore.signal()
        }
    }
    
    /**
     通信オブジェクトをキューに追加する
     
     - parameter connector: 通信オブジェクト
     */
    func add(_ connector: Connector) {
        self.semaphore.wait()
        defer {
            self.semaphore.signal()
        }
        var isExeRequest = false
        
        if connector.getQueueType() == .parallel {
            isExeRequest = true
            self.parallelQueue.add(connector)
        } else {
            if self.serialQueue.count == 0 {
                isExeRequest = true
            }
            self.serialQueue.add(connector)
        }
        
        if isExeRequest {
            
        }
    }
    
    /**
     リクエスト実行
     
     - parameter connector: 通信オブジェクト
     */
    fileprivate func exeRequest(_ connector: Connector) {
        
        DispatchQueue(label: "subthred", attributes: DispatchQueue.Attributes.concurrent).async {
            connector.exeRequest()
            
            DispatchQueue.main.async {
                self.semaphore.wait()
                defer {
                    self.semaphore.signal()
                }
                if connector.getQueueType() == .parallel {
                    let _ = connector.exeResponseCallback()
                    self.clear(connector)
                } else {
                    switch connector.exeResponseCallback() {
                    case .continue:
                        if self.serialQueue.index(of: connector) == 0 {
                            self.exeRequest(self.serialQueue.object(at: 0) as! Connector)
                        }
                    case .clear:
                        self.clearSerialQueue()
                    case .allClear:
                        self.clearAll()
                    case .stop:
                        break
                    }
                }
            }
        }
    }
    
    func restartSerial() {
        // TODO: - 処理考える
    }
    
    func restartParallel(_ connector: Connector) {
        // TODO: - 処理考える
    }
    
    fileprivate func responseFinishCaseSerial(_ connector: Connector) {
        
    }
    
    fileprivate func responseFinishCaseParallel(_ connector: Connector) {
        
    }
    
    fileprivate init() {
    }
    
    // MARK: - property
    
    /** Singleton Object */
    static let instance = QueueManager()
    
    fileprivate var serialQueue = NSMutableArray()
    
    fileprivate var parallelQueue = NSMutableArray()
    
    /** 排他制御のためのGCDオブジェクト */
    let semaphore = DispatchSemaphore(value: 1)
}
