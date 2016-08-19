//
//  KNBKCentralManager.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on  2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct KNBKPeripheralDiscovery {
    public var peripheral:KNBKPeripheral
    public var rssi:Int
}

@objc protocol KNBKCentralManagerDelegate : NSObjectProtocol {
    
    optional func centralManager(centralManager: KNBKCentralManager, powerStateChanged on: Bool)
}

public class KNBKCentralManager : NSObject, CBCentralManagerDelegate {
    
    //MARK: PRIVATE
    private var afterPowerOnPromise                 = KNBKPromise<Void>()
    private var afterPowerOffPromise                = KNBKPromise<Void>()
    internal var afterPeripheralDiscoveredPromise   = KNBKStreamPromise<KNBKPeripheralDiscovery>()

    private var cbCentralManager    : CBCentralManager!

    private let centralQueue    = dispatch_queue_create("com.Knodeit.central.main", DISPATCH_QUEUE_SERIAL)
    private var _isScanning     = false
    
    weak var delegate : KNBKCentralManagerDelegate!
    
    //MARK: INTERNAL
    internal var discoveredPeripherals   : Dictionary<CBPeripheral, KNBKPeripheral> = [:]
    
    //MARK: PUBLIC
    public var peripherals : [KNBKPeripheral] {
        return sorted(self.discoveredPeripherals.values.array, {(p1:KNBKPeripheral, p2:KNBKPeripheral) -> Bool in
            switch p1.discoveredAt.compare(p2.discoveredAt) {
            case .OrderedSame:
                return true
            case .OrderedDescending:
                return false
            case .OrderedAscending:
                return true
            }
        })
    }
    
    public class var sharedInstance : KNBKCentralManager {
        struct Static {
            static let instance = KNBKCentralManager()
        }
        return Static.instance
    }
    
    public var isScanning : Bool {
        return self._isScanning
    }

    public var poweredOn : Bool {
        return self.cbCentralManager.state == CBCentralManagerState.PoweredOn
    }
    
    public var poweredOff : Bool {
        return self.cbCentralManager.state == CBCentralManagerState.PoweredOff
    }

    //MARK: scanning
    public func startScanning(capacity:Int? = nil) -> KNBKFutureStream<(KNBKPeripheralDiscovery)> {
        return self.startScanningForServiceUUIDs(nil, capacity:capacity)
    }
    
    public func startScanningForServiceUUIDs(uuids:[CBUUID]!, capacity:Int? = nil) -> KNBKFutureStream<KNBKPeripheralDiscovery> {
        if !self._isScanning {
            KNBKLogger.debug("KNBKCentralManager#startScanningForServiceUUIDs: \(uuids)")
            self._isScanning = true
            if let capacity = capacity {
                self.afterPeripheralDiscoveredPromise = KNBKStreamPromise<KNBKPeripheralDiscovery>(capacity:capacity)
            } else {
                self.afterPeripheralDiscoveredPromise = KNBKStreamPromise<KNBKPeripheralDiscovery>()
            }
            self.cbCentralManager.scanForPeripheralsWithServices(uuids,options: nil)
        }
        return self.afterPeripheralDiscoveredPromise.future
    }
    
    public func stopScanning() {
        if self._isScanning {
            KNBKLogger.debug("KNBKCentralManager#stopScanning")
            self._isScanning = false
            self.cbCentralManager.stopScan()
        }
    }
    
    public func removeAllPeripherals() {
        self.discoveredPeripherals.removeAll(keepCapacity:false)
    }
    
    //MARK: connection
    public func disconnectAllPeripherals() {
        KNBKLogger.debug("KNBKCentralManager#disconnectAllPeripherals")
        for peripheral in self.peripherals {
            peripheral.disconnect()
        }
    }
    
    public func connectPeripheral(peripheral:KNBKPeripheral) {
        KNBKLogger.debug("KNBKCentralManager#connectPeripheral")
        self.cbCentralManager.connectPeripheral(peripheral.cbPeripheral, options:nil)
    }
    
    internal func cancelPeripheralConnection(peripheral:KNBKPeripheral) {
        KNBKLogger.debug("KNBKCentralManager#cancelPeripheralConnection")
        self.cbCentralManager.cancelPeripheralConnection(peripheral.cbPeripheral)
    }
    
    //MARK: power up
    public func powerOn() -> KNBKFuture<Void> {
        KNBKLogger.debug("KNBKCentralManager#powerOn")
        let future = self.afterPowerOnPromise.future
        self.afterPowerOnPromise = KNBKPromise<Void>()
        return future
    }
    
    public func powerOff() -> KNBKFuture<Void> {
        KNBKLogger.debug("KNBKCentralManager#powerOff")
        let future = self.afterPowerOffPromise.future
        self.afterPowerOffPromise = KNBKPromise<Void>()
        return future
    }
    
    //MARK: CBCentralManagerDelegate
    public func centralManager(_:CBCentralManager!, didConnectPeripheral peripheral:CBPeripheral!) {
        KNBKLogger.debug("KNBKCentralManager#didConnectPeripheral: \(peripheral.name)")
        if let bcPeripheral = self.discoveredPeripherals[peripheral] {
            bcPeripheral.didConnectPeripheral()
        }
    }
    
    public func centralManager(_:CBCentralManager!, didDisconnectPeripheral peripheral:CBPeripheral!, error:NSError!) {
        KNBKLogger.debug("KNBKCentralManager#didDisconnectPeripheral: \(peripheral.name)")
        if let bcPeripheral = self.discoveredPeripherals[peripheral] {
            bcPeripheral.didDisconnectPeripheral()
        }
    }
    
    public func centralManager(_:CBCentralManager!, didDiscoverPeripheral peripheral:CBPeripheral!, advertisementData:NSDictionary!, RSSI:NSNumber!) {
        if self.discoveredPeripherals[peripheral] == nil {
            let bcPeripheral = KNBKPeripheral(cbPeripheral:peripheral, advertisements:self.unpackAdvertisements(advertisementData), rssi:RSSI.integerValue)
            KNBKLogger.debug("KNBKCentralManager#didDiscoverPeripheral: \(bcPeripheral.name)")
            self.discoveredPeripherals[peripheral] = bcPeripheral
            self.afterPeripheralDiscoveredPromise.success(KNBKPeripheralDiscovery(peripheral:bcPeripheral, rssi:RSSI.integerValue))
        }
    }
    
    public func centralManager(_:CBCentralManager!, didFailToConnectPeripheral peripheral:CBPeripheral!, error:NSError!) {
        KNBKLogger.debug("KNBKCentralManager#didFailToConnectPeripheral")
        if let bcPeripheral = self.discoveredPeripherals[peripheral] {
            bcPeripheral.didFailToConnectPeripheral(error)
        }
    }
    
    public func centralManager(_:CBCentralManager!, didRetrieveConnectedPeripherals peripherals:[AnyObject]!) {
        KNBKLogger.debug("KNBKCentralManager#didRetrieveConnectedPeripherals")
    }
    
    public func centralManager(_:CBCentralManager!, didRetrievePeripherals peripherals:[AnyObject]!) {
        KNBKLogger.debug("KNBKCentralManager#didRetrievePeripherals")
    }
    
    // central manager state
    public func centralManager(_:CBCentralManager!, willRestoreState dict:NSDictionary!) {
        KNBKLogger.debug("KNBKCentralManager#willRestoreState")
    }
    
    public func centralManagerDidUpdateState(_:CBCentralManager!) {
        switch(self.cbCentralManager.state) {
        case .Unauthorized:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: Unauthorized")
            break
        case .Unknown:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: Unknown")
            break
        case .Unsupported:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: Unsupported")
            break
        case .Resetting:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: Resetting")
            break
        case .PoweredOff:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: PoweredOff")
            afterPowerOffPromise.success()
            if self.delegate.respondsToSelector(Selector("centralManager:powerStateChanged:")){
                self.delegate.centralManager?(self, powerStateChanged: false)
            }
            
            break
        case .PoweredOn:
            KNBKLogger.debug("KNBKCentralManager#centralManagerDidUpdateState: PoweredOn")
            afterPowerOnPromise.success()
            
            if self.delegate.respondsToSelector(Selector("centralManager:powerStateChanged:")){
                self.delegate.centralManager?(self, powerStateChanged: true)
            }
            
            break
        }
    }
    
    func resetCentral(){
        self.cbCentralManager = CBCentralManager(delegate:self, queue:self.centralQueue)
    }
    
    //MARK: INTERNAL INTERFACE
    internal class func sync(request:()->()) {
        KNBKCentralManager.sharedInstance.sync(request)
    }
    
    internal class func async(request:()->()) {
        KNBKCentralManager.sharedInstance.async(request)
    }
    
    internal class func delay(delay:Double, request:()->()) {
        KNBKCentralManager.sharedInstance.delay(delay, request)
    }
    
    internal func sync(request:()->()) {
        dispatch_sync(self.centralQueue, request)
    }
    
    internal func async(request:()->()) {
        dispatch_async(self.centralQueue, request)
    }
    
    internal func delay(delay:Double, request:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Float(delay)*Float(NSEC_PER_SEC)))
        dispatch_after(popTime, self.centralQueue, request)
    }
    
    
    
    
    //MARK: PRIVATE
    private override init() {
        super.init()
        self.cbCentralManager = CBCentralManager(delegate:self, queue:self.centralQueue)
    }
    
    private func unpackAdvertisements(advertDictionary:NSDictionary!) -> Dictionary<String,String> {
        KNBKLogger.debug("KNBKCentralManager#unpackAdvertisements found \(advertDictionary.count) advertisements")
        var advertisements = Dictionary<String, String>()
        func addKey(key:String, andValue value:AnyObject) -> () {
            if value is NSString {
                advertisements[key] = (value as? String)
            } else {
                advertisements[key] = value.stringValue
            }
            KNBKLogger.debug("KNBKCentralManager#unpackAdvertisements key:\(key), value:\(advertisements[key])")
        }
        if advertDictionary != nil {
            for keyObject : AnyObject in advertDictionary.allKeys {
                let key = keyObject as String
                let value : AnyObject! = advertDictionary.objectForKey(keyObject)
                if value is NSArray {
                    for v : AnyObject in (value as NSArray) {
                        addKey(key, andValue:value)
                    }
                } else {
                    addKey(key, andValue:value)
                }                
            }
        }
        KNBKLogger.debug("KNBKCentralManager#unpackAdvertisements unpacked \(advertisements.count) advertisements")
        return advertisements
    }
    
}
