//
//  Connector.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKConnectorator {

    private var timeoutCount    = 0
    private var disconnectCount = 0
    
    private let promise : KNBKStreamPromise<KNBKPeripheral>

    public var timeoutRetries           = -1
    public var disconnectRetries        = -1
    public var connectionTimeout        = 10.0
    public var characteristicTimeout    = 10.0

    public init () {
        self.promise = KNBKStreamPromise<KNBKPeripheral>()
    }

    public init (capacity:Int) {
        self.promise = KNBKStreamPromise<KNBKPeripheral>(capacity:capacity)
    }
    
    convenience public init(initializer:((connectorator:KNBKConnectorator) -> Void)?) {
        self.init()
        if let initializer = initializer {
            initializer(connectorator:self)
        }
    }

    convenience public init(capacity:Int, initializer:((connectorator:KNBKConnectorator) -> Void)?) {
        self.init(capacity:capacity)
        if let initializer = initializer {
            initializer(connectorator:self)
        }
    }

    public func onConnect() -> KNBKFutureStream<KNBKPeripheral> {
        return self.promise.future
    }
    
    internal func didTimeout() {
        KNBKLogger.debug("KNBKConnectorator#didTimeout")
        if self.timeoutRetries > 0 {
            if self.timeoutCount < self.timeoutRetries {
                self.callDidTimeout()
                ++self.timeoutCount
            } else {
                self.callDidGiveUp()
                self.timeoutCount = 0
            }
        } else {
            self.callDidTimeout()
        }
    }

    internal func didDisconnect() {
        KNBKLogger.debug("KNBKConnectorator#didDisconnect")
        if self.disconnectRetries > 0 {
            if self.disconnectCount < self.disconnectRetries {
                ++self.disconnectCount
                self.callDidDisconnect()
            } else {
                self.disconnectCount = 0
                self.callDidGiveUp()
            }
        } else {
            self.callDidDisconnect()
        }
    }
    
    internal func didForceDisconnect() {
        KNBKLogger.debug("KNBKConnectorator#didForceDisconnect")
        self.promise.failure(KNBKError.connectoratorForcedDisconnect)
    }
    
    internal func didConnect(peripheral:KNBKPeripheral) {
        KNBKLogger.debug("KNBKConnectorator#didConnect")
        self.promise.success(peripheral)
    }
    
    internal func didFailConnect(error:NSError?) {
        KNBKLogger.debug("KNBKConnectorator#didFailConnect")
        if let error = error {
            self.promise.failure(error)
        } else {
            self.promise.failure(KNBKError.connectoratorFailed)
        }
    }
    
    internal func callDidTimeout() {
        self.promise.failure(KNBKError.connectoratorDisconnect)
    }
    
    internal func callDidDisconnect() {
        self.promise.failure(KNBKError.connectoratorTimeout)
    }
    
    internal func callDidGiveUp() {
        self.promise.failure(KNBKError.connectoratorGiveUp)
    }
}