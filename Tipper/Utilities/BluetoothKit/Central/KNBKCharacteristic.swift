//
//  KNBKCharacteristic.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKCharacteristic {

    private var notificationUpdatePromise          : KNBKStreamPromise<KNBKCharacteristic>?
    private var notificationStateChangedPromise    = KNBKPromise<KNBKCharacteristic>()
    private var readPromise                        = KNBKPromise<KNBKCharacteristic>()
    private var writePromise                       = KNBKPromise<KNBKCharacteristic>()
    
    private var reading = false
    private var writing = false
    
    private var readSequence    = 0
    private var writeSequence   = 0
    private let defaultTimeout  = 10.0
    
    internal let cbCharacteristic : CBCharacteristic
    internal let _service         : KNBKService
    internal let profile          : KNBKCharacteristicProfile!
    
    public var service : KNBKService {
        return self._service
    }
    
    public var name : String {
        return self.profile.name
    }
    
    public var uuid : CBUUID! {
        return self.cbCharacteristic.UUID
    }
    
    public var properties : CBCharacteristicProperties {
        return self.cbCharacteristic.properties
    }

    public var isNotifying : Bool {
        return self.cbCharacteristic.isNotifying
    }
    
    public var isBroadcasted : Bool {
        return self.cbCharacteristic.isBroadcasted
    }
    
    public var value : NSData! {
        return self.cbCharacteristic.value
    }

    public var stringValues : Dictionary<String, String>? {
        if self.value != nil {
            return self.profile.stringValues(self.value)
        } else {
            return nil
        }
    }
    
    public var anyValue : Any? {
        if self.value != nil {
            return self.profile.anyValue(self.value)
        } else {
            return nil
        }
    }
    
    public var discreteStringValues : [String] {
        return self.profile.discreteStringValues
    }
    
    public func startNotifying() -> KNBKFuture<KNBKCharacteristic> {
        self.notificationStateChangedPromise = KNBKPromise<KNBKCharacteristic>()
        if self.propertyEnabled(.Notify) {
            self.service.peripheral.cbPeripheral .setNotifyValue(true, forCharacteristic:self.cbCharacteristic)
        }
        return self.notificationStateChangedPromise.future
    }

    public func stopNotifying() -> KNBKFuture<KNBKCharacteristic> {
        self.notificationStateChangedPromise = KNBKPromise<KNBKCharacteristic>()
        if self.propertyEnabled(.Notify) {
            self.service.peripheral.cbPeripheral .setNotifyValue(false, forCharacteristic:self.cbCharacteristic)
        }
        return self.notificationStateChangedPromise.future
    }

    public func recieveNotificationUpdates(capacity:Int? = nil) -> KNBKFutureStream<KNBKCharacteristic> {
        if let capacity = capacity {
            self.notificationUpdatePromise = KNBKStreamPromise<KNBKCharacteristic>(capacity:capacity)
        } else {
            self.notificationUpdatePromise = KNBKStreamPromise<KNBKCharacteristic>()
        }
        return self.notificationUpdatePromise!.future
    }
    
    public func stopNotificationUpdates() {
        self.notificationUpdatePromise = nil
    }
    
    public func propertyEnabled(property:CBCharacteristicProperties) -> Bool {
        return (self.properties.rawValue & property.rawValue) > 0
    }
    
    public func read() -> KNBKFuture<KNBKCharacteristic> {
        self.readPromise = KNBKPromise<KNBKCharacteristic>()
        if self.propertyEnabled(.Read) {
            KNBKLogger.debug("KNBKCharacteristic#read: \(self.uuid.UUIDString)")
            self.service.peripheral.cbPeripheral.readValueForCharacteristic(self.cbCharacteristic)
            self.reading = true
            ++self.readSequence
            self.timeoutRead(self.readSequence)
        } else {
            self.readPromise.failure(KNBKError.characteristicReadNotSupported)
        }
        return self.readPromise.future
    }

    public func writeData(value:NSData) -> KNBKFuture<KNBKCharacteristic> {
        self.writePromise = KNBKPromise<KNBKCharacteristic>()
        if self.propertyEnabled(.Write) {
            KNBKLogger.debug("KNBKCharacteristic#write: value=\(value.hexStringValue()), uuid=\(self.uuid.UUIDString)")
            self.service.peripheral.cbPeripheral.writeValue(value, forCharacteristic:self.cbCharacteristic, type:.WithResponse)
            self.writing = true
            ++self.writeSequence
            self.timeoutWrite(self.writeSequence)
        } else {
            self.writePromise.failure(KNBKError.characteristicWriteNotSupported)
        }
        return self.writePromise.future
    }

    public func writeString(stringValue:Dictionary<String, String>) -> KNBKFuture<KNBKCharacteristic> {
        if let value = self.profile.dataFromStringValue(stringValue) {
            return self.writeData(value)
        } else {
            self.writePromise = KNBKPromise<KNBKCharacteristic>()
            self.writePromise.failure(KNBKError.characteristicNotSerilaizable)
            return self.writePromise.future
        }
    }

    public func write(anyValue:Any) -> KNBKFuture<KNBKCharacteristic> {
        if let value = self.profile.dataFromAnyValue(anyValue) {
            return self.writeData(value)
        } else {
            self.writePromise = KNBKPromise<KNBKCharacteristic>()
            self.writePromise.failure(KNBKError.characteristicNotSerilaizable)
            return self.writePromise.future
        }
    }

    private func timeoutRead(sequence:Int) {
        KNBKLogger.debug("KNBKCharacteristic#timeoutRead: sequence \(sequence), timeout:\(self.readWriteTimeout())")
        KNBKCentralManager.delay(self.readWriteTimeout()) {
            if sequence == self.readSequence && self.reading {
                self.reading = false
                KNBKLogger.debug("KNBKCharacteristic#timeoutRead: timing out sequence=\(sequence), current readSequence=\(self.readSequence)")
                self.readPromise.failure(KNBKError.characteristicReadTimeout)
            } else {
                KNBKLogger.debug("KNBKCharacteristic#timeoutRead: expired")
            }
        }
    }

    private func timeoutWrite(sequence:Int) {
        KNBKLogger.debug("KNBKCharacteristic#timeoutWrite: sequence \(sequence), timeout:\(self.readWriteTimeout())")
        KNBKCentralManager.delay(self.readWriteTimeout()) {
            if sequence == self.writeSequence && self.writing {
                self.writing = false
                KNBKLogger.debug("KNBKCharacteristic#timeoutWrite: timing out sequence=\(sequence), current writeSequence=\(self.writeSequence)")
                self.writePromise.failure(KNBKError.characteristicWriteTimeout)
            } else {
                KNBKLogger.debug("KNBKCharacteristic#timeoutWrite: expired")
            }
        }
    }
    
    private func readWriteTimeout() -> Double {
        if let connectorator = self.service.peripheral.connectorator {
            return connectorator.characteristicTimeout
        } else {
            return self.defaultTimeout
        }
    }

    internal init(cbCharacteristic:CBCharacteristic, service:KNBKService) {
        self.cbCharacteristic = cbCharacteristic
        self._service = service
        self.profile = KNBKCharacteristicProfile(uuid:self.uuid.UUIDString, name:"Unknown")
        if let serviceProfile = KNBKProfileManager.sharedInstance.serviceProfiles[service.uuid] {
            if let characteristicProfile = serviceProfile.characteristicProfiles[cbCharacteristic.UUID] {
                self.profile = characteristicProfile
            }
        }
    }
    
    internal func didDiscover() {
        KNBKLogger.debug("KNBKCharacteristic#didDiscover:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
        if let afterDiscoveredPromise = self.profile.afterDiscoveredPromise {
            afterDiscoveredPromise.success(self)
        }
    }
    
    internal func didUpdateNotificationState(error:NSError!) {
        if let error = error {
            KNBKLogger.debug("KNBKCharacteristic#didUpdateNotificationState Failed:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            self.notificationStateChangedPromise.failure(error)
        } else {
            KNBKLogger.debug("KNBKCharacteristic#didUpdateNotificationState Success:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            self.notificationStateChangedPromise.success(self)
        }
    }
    
    internal func didUpdate(error:NSError!) {
        self.reading = false
        if let error = error {
            KNBKLogger.debug("KNBKCharacteristic#didUpdate Failed:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            if self.isNotifying {
                if let notificationUpdatePromise = self.notificationUpdatePromise {
                    notificationUpdatePromise.failure(error)
                }
            } else {
                self.readPromise.failure(error)
            }
        } else {
            KNBKLogger.debug("KNBKCharacteristic#didUpdate Success:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            if self.isNotifying {
                if let notificationUpdatePromise = self.notificationUpdatePromise {
                    notificationUpdatePromise.success(self)
                }
            } else {
                self.readPromise.success(self)
            }
        }
    }
    
    internal func didWrite(error:NSError!) {
        self.writing = false
        if let error = error {
            KNBKLogger.debug("KNBKCharacteristic#didWrite Failed:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            self.writePromise.failure(error)
        } else {
            KNBKLogger.debug("KNBKCharacteristic#didWrite Success:  uuid=\(self.uuid.UUIDString), name=\(self.name)")
            self.writePromise.success(self)
        }
    }
}
