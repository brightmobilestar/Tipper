//
//  KNBKTimedScannerator.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKTimedScannerator {
    
    internal var timeoutSeconds = 10.0

    internal var _isScanning = false
    
    public var isScanning : Bool {
        return self._isScanning
    }
    
    public class var sharedInstance : KNBKTimedScannerator {
        struct Static {
            static let instance = KNBKTimedScannerator()
        }
        return Static.instance
    }

    public init() {
    }
    
    public func startScanning(timeoutSeconds:Double, capacity:Int? = nil) -> KNBKFutureStream<KNBKPeripheralDiscovery> {
        self.timeoutSeconds = timeoutSeconds
        self._isScanning = true
        self.timeoutScan()
        return KNBKCentralManager.sharedInstance.startScanning(capacity:capacity)
    }
    
    public func startScanningForServiceUUIDs(timeoutSeconds:Double, uuids:[CBUUID]!, capacity:Int? = nil) -> KNBKFutureStream<KNBKPeripheralDiscovery> {
        self.timeoutSeconds = timeoutSeconds
        self._isScanning = true
        self.timeoutScan()
        return KNBKCentralManager.sharedInstance.startScanningForServiceUUIDs(uuids, capacity:capacity)
    }
    
    public func stopScanning() {
        self._isScanning = false
        KNBKCentralManager.sharedInstance.stopScanning()
    }

    internal func timeoutScan() {
        KNBKLogger.debug("Scannerator#timeoutScan: \(self.timeoutSeconds)s")
        KNBKCentralManager.sharedInstance.delay(self.timeoutSeconds) {
            KNBKCentralManager.sharedInstance.afterPeripheralDiscoveredPromise.failure(KNBKError.peripheralDiscoveryTimeout)
        }
    }

}
