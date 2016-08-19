//
//  KNBKPeripheralManager.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol KNBKPeripheralManagerDelegate : NSObjectProtocol {
    
    optional func peripheralManager(peripheralManager: KNBKPeripheralManager, powerStateChanged on: Bool)
}

public class KNBKPeripheralManager : NSObject, CBPeripheralManagerDelegate {
    
    private let WAIT_FOR_ADVERTISING_TO_STOP_POLLING_INTERVAL : Float = 0.25
    
    private var afterAdvertisingStartedPromise      = KNBKPromise<Void>()
    private var afterAdvertsingStoppedPromise       = KNBKPromise<Void>()
    private var afterPowerOnPromise                 = KNBKPromise<Void>()
    private var afterPowerOffPromise                = KNBKPromise<Void>()
    private var afterSeriviceAddPromise             = KNBKPromise<Void>()
    
    private let peripheralQueue = dispatch_queue_create("com.Knodeit.peripheral.main", DISPATCH_QUEUE_SERIAL)
    
    private var _name : String?

    private var _isPoweredOn    = false
    private var serviceAdded    = false

    internal var cbPeripheralManager        : CBPeripheralManager!
    internal var configuredServices         : Dictionary<CBUUID, KNBKMutableService>                    = [:]
    internal var configuredCharcteristics   : Dictionary<CBCharacteristic, KNBKMutableCharacteristic>   = [:]

    
    weak var delegate : KNBKPeripheralManagerDelegate!
    
    public var isAdvertising : Bool {
        return self.cbPeripheralManager.isAdvertising
    }
    
    public var state : CBPeripheralManagerState {
        return self.cbPeripheralManager.state
    }
    
    public var services : [KNBKMutableService] {
        return self.configuredServices.values.array
    }
    
    public var name : String? {
        return self._name
    }
    
    public var isPoweredOn : Bool {
        return self._isPoweredOn
    }

    public class var sharedInstance : KNBKPeripheralManager {
        struct Static {
            static let instance = KNBKPeripheralManager()
        }
        return Static.instance
    }
    
    public func service(uuid:CBUUID) -> KNBKMutableService? {
        return self.configuredServices[uuid]
    }
    
    // power on
    public func powerOn() -> KNBKFuture<Void> {
        KNBKLogger.debug("KNBKPeripheralManager#powerOn")
        let future = self.afterPowerOnPromise.future
        self.afterPowerOnPromise = KNBKPromise<Void>()
        return future
    }
    
    public func powerOff() -> KNBKFuture<Void> {
        KNBKLogger.debug("KNBKPeripheralManager#powerOff")
        let future = self.afterPowerOffPromise.future
        self.afterPowerOffPromise = KNBKPromise<Void>()
        return future
    }

    // advertising
    public func startAdvertising(name:String, uuids:[CBUUID]?) -> KNBKFuture<Void> {
        self._name = name
        self.afterAdvertisingStartedPromise = KNBKPromise<Void>()
        var advertisementData : [NSObject:AnyObject] = [CBAdvertisementDataLocalNameKey:name]
        if let uuids = uuids {
            advertisementData[CBAdvertisementDataServiceUUIDsKey] = uuids
        }
        self.cbPeripheralManager.startAdvertising(advertisementData)
        return self.afterAdvertisingStartedPromise.future
    }
    
    public func startAdvertising(name:String) -> KNBKFuture<Void> {
        return self.startAdvertising(name, uuids:nil)
    }
    
    public func stopAdvertising() -> KNBKFuture<Void> {
        self._name = nil
        self.afterAdvertsingStoppedPromise = KNBKPromise<Void>()
        self.cbPeripheralManager.stopAdvertising()
        dispatch_async(self.peripheralQueue, {self.lookForAdvertisingToStop()})
        return self.afterAdvertsingStoppedPromise.future
    }
    
    // services
    public func addService(service:KNBKMutableService) -> KNBKFuture<Void> {
        if !self.isAdvertising {
            self.afterSeriviceAddPromise = KNBKPromise<Void>()
            self.configuredServices[service.uuid] = service
            self.cbPeripheralManager.addService(service.cbMutableService)
        } else {
            NSException(name:"Add service failed", reason: "KNBKPeripheral is advertising", userInfo: nil).raise()
        }
        return self.afterSeriviceAddPromise.future
    }
    
    public func addServices(services:[KNBKMutableService]) -> KNBKFuture<Void> {
        KNBKLogger.debug("KNBKPeripheralManager#addServices: service count \(services.count)")
        let promise = KNBKPromise<Void>()
        self.addService(promise, services:services)
        return promise.future
    }

    private func addService(promise:KNBKPromise<Void>, services:[KNBKMutableService]) {
        if services.count > 0 {
            let future = self.addService(services[0])
            future.onSuccess {
                if services.count > 1 {
                    let servicesTail = Array(services[1...services.count-1])
                    KNBKLogger.debug("KNBKPeripheralManager#addServices: services remaining \(servicesTail.count)")
                    self.addService(promise, services:servicesTail)
                } else {
                    KNBKLogger.debug("KNBKPeripheralManager#addServices: completed")
                    promise.success()
                }
            }
            future.onFailure {(error) in
                let future = self.removeAllServices()
                future.onSuccess {
                    KNBKLogger.debug("KNBKPeripheralManager#addServices: failed '\(error.localizedDescription)'")
                    promise.failure(error)
                }
            }
        }
    }
    
    public func removeService(service:KNBKMutableService) -> KNBKFuture<Void> {
        let promise = KNBKPromise<Void>()
        if !self.isAdvertising {
            KNBKLogger.debug("KNBKPeripheralManager#removeService: \(service.uuid.UUIDString)")
            let removeCharacteristics = Array(self.configuredCharcteristics.keys).filter{(cbCharacteristic) in
                                            for bcCharacteristic in service.characteristics {
                                                if let uuid = cbCharacteristic.UUID {
                                                    if uuid == bcCharacteristic.uuid {
                                                        return true
                                                    }
                                                }
                                            }
                                            return false
                                        }
            for cbCharacteristic in removeCharacteristics {
                self.configuredCharcteristics.removeValueForKey(cbCharacteristic)
            }
            self.configuredServices.removeValueForKey(service.uuid)
            self.cbPeripheralManager.removeService(service.cbMutableService)
            promise.success()
        } else {
            promise.failure(KNBKError.peripheralManagerIsAdvertising)
        }
        return promise.future
    }
    
    public func removeAllServices() -> KNBKFuture<Void> {
        let promise = KNBKPromise<Void>()
        if !self.isAdvertising {
            KNBKLogger.debug("KNBKPeripheralManager#removeAllServices")
            self.configuredServices.removeAll(keepCapacity:false)
            self.configuredCharcteristics.removeAll(keepCapacity:false)
            self.cbPeripheralManager.removeAllServices()
            promise.success()
        } else {
            promise.failure(KNBKError.peripheralManagerIsAdvertising)
        }
        return promise.future
    }

    // CBPeripheralManagerDelegate
    public func peripheralManagerDidUpdateState(_:CBPeripheralManager!) {
        switch self.state {
        case CBPeripheralManagerState.PoweredOn:
            KNBKLogger.debug("KNBKPeripheralManager#peripheralManagerDidUpdateState: poweredOn")
            self.afterPowerOnPromise.success()
            self._isPoweredOn = true
            if self.delegate.respondsToSelector(Selector("peripheralManager:powerStateChanged:")){
                self.delegate.peripheralManager!(self, powerStateChanged: true)
            }
            
            break
        case CBPeripheralManagerState.PoweredOff:
            KNBKLogger.debug("KNBKPeripheralManager#peripheralManagerDidUpdateState: poweredOff")
            self.afterPowerOffPromise.success()
            self._isPoweredOn = false
            if self.delegate.respondsToSelector(Selector("peripheralManager:powerStateChanged:")){
                self.delegate.peripheralManager!(self, powerStateChanged: false)
            }
            break
        case CBPeripheralManagerState.Resetting:
            break
        case CBPeripheralManagerState.Unsupported:
            break
        case CBPeripheralManagerState.Unauthorized:
            break
        case CBPeripheralManagerState.Unknown:
            break
        }
    }
    
    public func peripheralManager(_:CBPeripheralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
    }
    
    public func peripheralManagerDidStartAdvertising(_:CBPeripheralManager!, error:NSError!) {
        if let error = error {
            KNBKLogger.debug("KNBKPeripheralManager#peripheralManagerDidStartAdvertising: Failed '\(error.localizedDescription)'")
            self.afterAdvertisingStartedPromise.failure(error)
        } else {
            KNBKLogger.debug("KNBKPeripheralManager#peripheralManagerDidStartAdvertising: Success")
            self.afterAdvertisingStartedPromise.success()
        }
    }
    
    public func peripheralManager(_:CBPeripheralManager!, didAddService service:CBService!, error:NSError!) {
        if let bcService = self.configuredServices[service.UUID] {
            self.serviceAdded = true
            if let error = error {
                KNBKLogger.debug("KNBKPeripheralManager#didAddService: Failed '\(error.localizedDescription)'")
                self.configuredServices.removeValueForKey(service.UUID)
                self.afterSeriviceAddPromise.failure(error)
            } else {
                KNBKLogger.debug("KNBKPeripheralManager#didAddService: Success")
                self.afterSeriviceAddPromise.success()
            }
        }
    }
    
    public func peripheralManager(_:CBPeripheralManager!, central:CBCentral!, didSubscribeToCharacteristic characteristic:CBCharacteristic!) {
        KNBKLogger.debug("KNBKPeripheralManager#didSubscribeToCharacteristic")
    }
    
    public func peripheralManager(_:CBPeripheralManager!, central:CBCentral!, didUnsubscribeFromCharacteristic characteristic:CBCharacteristic!) {
        KNBKLogger.debug("KNBKPeripheralManager#didUnsubscribeFromCharacteristic")
    }
    
    public func peripheralManagerIsReadyToUpdateSubscribers(_:CBPeripheralManager!) {
        KNBKLogger.debug("KNBKPeripheralManager#peripheralManagerIsReadyToUpdateSubscribers")
    }
    
    public func peripheralManager(_:CBPeripheralManager!, didReceiveReadRequest request:CBATTRequest!) {
        KNBKLogger.debug("KNBKPeripheralManager#didReceiveReadRequest: chracteracteristic \(request.characteristic.UUID)")
        if let characteristic = self.configuredCharcteristics[request.characteristic] {
            //KNBKLogger.debug("Responding with data: \(characteristic.stringValues)")
            request.value = characteristic.value
            self.cbPeripheralManager.respondToRequest(request, withResult:CBATTError.Success)
        } else {
            KNBKLogger.debug("Error: characteristic not found")
            self.cbPeripheralManager.respondToRequest(request, withResult:CBATTError.AttributeNotFound)
        }
    }
    
    public func peripheralManager(_:CBPeripheralManager!, didReceiveWriteRequests requests:[AnyObject]!) {
        KNBKLogger.debug("KNBKPeripheralManager#didReceiveWriteRequests")
        for request in requests {
            if let cbattRequest = request as? CBATTRequest {
                if let characteristic = self.configuredCharcteristics[cbattRequest.characteristic] {
                    KNBKLogger.debug("characteristic write request received for \(characteristic.uuid.UUIDString)")
                    characteristic.value = request.value
                    if let processWriteRequestPromise = characteristic.processWriteRequestPromise {
                        processWriteRequestPromise.success(cbattRequest)
                    }
                } else {
                    KNBKLogger.debug("Error: characteristic \(cbattRequest.characteristic.UUID.UUIDString) not found")
                }
            } else {
                KNBKLogger.debug("Error: request cast failed")
            }
        }
    }
    
    private override init() {
        super.init()
        self.cbPeripheralManager = CBPeripheralManager(delegate:self, queue:self.peripheralQueue)
    }
    
    private func lookForAdvertisingToStop() {
        if self.isAdvertising {
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(WAIT_FOR_ADVERTISING_TO_STOP_POLLING_INTERVAL * Float(NSEC_PER_SEC)))
            dispatch_after(popTime, self.peripheralQueue, {
                self.lookForAdvertisingToStop()
            })
        } else {
            KNBKLogger.debug("KNBKPeripheral#lookForAdvertisingToStop: Advertising stopped")
            self.afterAdvertsingStoppedPromise.success()
        }
    }    
}
