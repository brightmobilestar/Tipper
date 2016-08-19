//
//  KNBKPeripheral.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralConnectionError {
    case None
    case Timeout
}

public class KNBKPeripheral : NSObject, CBPeripheralDelegate {

    private var servicesDiscoveredPromise   = KNBKPromise<[KNBKService]>()
    
    private var connectionSequence          = 0
    private var discoveredServices          = Dictionary<CBUUID, KNBKService>()
    private var discoveredCharacteristics   = Dictionary<CBCharacteristic, KNBKCharacteristic>()
    private var currentError                = PeripheralConnectionError.None
    private var forcedDisconnect            = false
    
    private let defaultConnectionTimeout    = Double(10.0)
    
    private let _discoveredAt               = NSDate()
    private var _connectedAt                : NSDate?
    private var _disconnectedAt             : NSDate?

    private var _connectorator  : KNBKConnectorator?

    internal let cbPeripheral    : CBPeripheral!

    public let advertisements  : Dictionary<String, String>!
    public let rssi            : Int!

    public var name : String {
        if let name = cbPeripheral.name {
            return name
        } else {
            return "Unknown"
        }
    }
    
    public var discoveredAt : NSDate {
        return self._discoveredAt
    }
    
    public var connectedAt : NSDate? {
        return self._connectedAt
    }

    public var disconnectedAt : NSDate? {
        return self._disconnectedAt
    }

    public var state : CBPeripheralState {
        return self.cbPeripheral.state
    }
    
    public var identifier : NSUUID! {
        return self.cbPeripheral.identifier
    }
    
    public var services : [KNBKService] {
        return self.discoveredServices.values.array
    }
    
    public var connectorator : KNBKConnectorator? {
        return self._connectorator
    }
    
    public init(cbPeripheral:CBPeripheral, advertisements:Dictionary<String, String>, rssi:Int) {
        super.init()
        self.cbPeripheral = cbPeripheral
        self.cbPeripheral.delegate = self
        self.advertisements = advertisements
        self.currentError = .None
        self.rssi = rssi
    }
    
    // connect
    public func reconnect() {
        if self.state == .Disconnected {
            KNBKLogger.debug("KNBKPeripheral#reconnect: \(self.name)")
            KNBKCentralManager.sharedInstance.connectPeripheral(self)
            self.forcedDisconnect = false
            ++self.connectionSequence
            self.timeoutConnection(self.connectionSequence)
        }
    }
     
    public func connect(connectorator:KNBKConnectorator?=nil) {
        KNBKLogger.debug("KNBKPeripheral#connect: \(self.name)")
        self._connectorator = connectorator
        self.reconnect()
    }
    
    public func disconnect() {
        self.forcedDisconnect = true
        KNBKCentralManager.sharedInstance.discoveredPeripherals.removeValueForKey(self.cbPeripheral)
        if self.state == .Connected {
            KNBKLogger.debug("KNBKPeripheral#disconnect: \(self.name)")
            KNBKCentralManager.sharedInstance.cancelPeripheralConnection(self)
        } else {
            self.didDisconnectPeripheral()
        }
    }
    
    public func terminate() {
        self.disconnect()
    }

    // service discovery
    public func discoverAllServices() -> KNBKFuture<[KNBKService]> {
        KNBKLogger.debug("KNBKPeripheral#discoverAllServices: \(self.name)")
        return self.discoverServices(nil)
    }

    public func discoverServices(services:[CBUUID]!) -> KNBKFuture<[KNBKService]> {
        KNBKLogger.debug("KNBKPeripheral#discoverAllServices: \(self.name)")
        self.servicesDiscoveredPromise = KNBKPromise<[KNBKService]>()
        self.discoverIfConnected(services)
        return self.servicesDiscoveredPromise.future
    }

    public func discoverAllPeripheralServices() -> KNBKFuture<[KNBKService]> {
        KNBKLogger.debug("KNBKPeripheral#discoverAllPeripheralServices: \(self.name)")
        return self.discoverPeripheralServices(nil)
    }

    public func discoverPeripheralServices(services:[CBUUID]!) -> KNBKFuture<[KNBKService]> {
        let peripheralDiscoveredPromise = KNBKPromise<[KNBKService]>()
        KNBKLogger.debug("KNBKPeripheral#discoverPeripheralServices: \(self.name)")
        let servicesDiscoveredFuture = self.discoverServices(services)
        servicesDiscoveredFuture.onSuccess {services in
            if self.services.count > 1 {
                self.discoverService(self.services[0], tail:Array(self.services[1..<self.services.count]), promise:peripheralDiscoveredPromise)
            } else {
                let discoveryFuture = self.services[0].discoverAllCharacteristics()
                discoveryFuture.onSuccess {_ in
                    peripheralDiscoveredPromise.success(self.services)
                }
                discoveryFuture.onFailure {error in
                    peripheralDiscoveredPromise.failure(error)
                }
            }
        }
        servicesDiscoveredFuture.onFailure{(error) in
           peripheralDiscoveredPromise.failure(error)
        }
        return peripheralDiscoveredPromise.future
    }

    // CBPeripheralDelegate
    // peripheral
    public func peripheralDidUpdateName(_:CBPeripheral!) {
        KNBKLogger.debug("KNBKPeripheral#peripheralDidUpdateName")
    }
    
    public func peripheral(_:CBPeripheral!, didModifyServices invalidatedServices:[AnyObject]!) {
        KNBKLogger.debug("KNBKPeripheral#didModifyServices")
    }
    
    // services
    public func peripheral(peripheral:CBPeripheral!, didDiscoverServices error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didDiscoverServices: \(self.name)")
        self.clearAll()
        if let error = error {
            self.servicesDiscoveredPromise.failure(error)
        } else {
            if let cbServices = peripheral.services {
                for cbService : AnyObject in cbServices {
                    let bcService = KNBKService(cbService:cbService as CBService, peripheral:self)
                    self.discoveredServices[bcService.uuid] = bcService
                    KNBKLogger.debug("KNBKPeripheral#didDiscoverServices: uuid=\(bcService.uuid.UUIDString), name=\(bcService.name)")
                }
                self.servicesDiscoveredPromise.success(self.services)
            } else {
                self.servicesDiscoveredPromise.success([KNBKService]())
            }
        }
    }
    
    public func peripheral(_:CBPeripheral!, didDiscoverIncludedServicesForService service:CBService!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didDiscoverIncludedServicesForService: \(self.name)")
    }
    
    // characteristics
    public func peripheral(_:CBPeripheral!, didDiscoverCharacteristicsForService service:CBService!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didDiscoverCharacteristicsForService: \(self.name)")
        if let service = service {
            if let bcService = self.discoveredServices[service.UUID] {
                if let cbCharacteristic = service.characteristics {
                    bcService.didDiscoverCharacteristics(error)
                    if error == nil {
                        for characteristic : AnyObject in cbCharacteristic {
                            let cbCharacteristic = characteristic as CBCharacteristic
                            self.discoveredCharacteristics[cbCharacteristic] = bcService.discoveredCharacteristics[characteristic.UUID]
                        }
                    }
                }
            }
        }
    }
    
    public func peripheral(_:CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didUpdateNotificationStateForCharacteristic")
        if let characteristic = characteristic {
            if let bcCharacteristic = self.discoveredCharacteristics[characteristic] {
                KNBKLogger.debug("KNBKPeripheral#didUpdateNotificationStateForCharacteristic: uuid=\(bcCharacteristic.uuid.UUIDString), name=\(bcCharacteristic.name)")
                bcCharacteristic.didUpdateNotificationState(error)
            }
        }
    }

    public func peripheral(_:CBPeripheral!, didUpdateValueForCharacteristic characteristic:CBCharacteristic!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didUpdateValueForCharacteristic")
        if let characteristic = characteristic {
            if let bcCharacteristic = self.discoveredCharacteristics[characteristic] {
                KNBKLogger.debug("KNBKPeripheral#didUpdateValueForCharacteristic: uuid=\(bcCharacteristic.uuid.UUIDString), name=\(bcCharacteristic.name)")
                bcCharacteristic.didUpdate(error)
            }
        }
    }

    public func peripheral(_:CBPeripheral!, didWriteValueForCharacteristic characteristic:CBCharacteristic!, error: NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didWriteValueForCharacteristic")
        if let characteristic = characteristic {
            if let bcCharacteristic = self.discoveredCharacteristics[characteristic] {
                KNBKLogger.debug("KNBKPeripheral#didWriteValueForCharacteristic: uuid=\(bcCharacteristic.uuid.UUIDString), name=\(bcCharacteristic.name)")
                bcCharacteristic.didWrite(error)
            }
        }
    }
    
    // descriptors
    public func peripheral(_:CBPeripheral!, didDiscoverDescriptorsForCharacteristic characteristic:CBCharacteristic!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didDiscoverDescriptorsForCharacteristic")
    }
    
    public func peripheral(_:CBPeripheral!, didUpdateValueForDescriptor descriptor:CBDescriptor!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didUpdateValueForDescriptor")
    }
    
    public func peripheral(_:CBPeripheral!, didWriteValueForDescriptor descriptor:CBDescriptor!, error:NSError!) {
        KNBKLogger.debug("KNBKPeripheral#didWriteValueForDescriptor")
    }
    
    private func timeoutConnection(sequence:Int) {
        let central = KNBKCentralManager.sharedInstance
        var timeout = self.defaultConnectionTimeout
        if let connectorator = self._connectorator {
            timeout = connectorator.connectionTimeout
        }
        KNBKLogger.debug("KNBKPeripheral#timeoutConnection: sequence \(sequence), timeout:\(timeout)")
        central.delay(timeout) {
            if self.state != .Connected && sequence == self.connectionSequence && !self.forcedDisconnect {
                KNBKLogger.debug("KNBKPeripheral#timeoutConnection: timing out sequence=\(sequence), current connectionSequence=\(self.connectionSequence)")
                self.currentError = .Timeout
                central.cancelPeripheralConnection(self)
            } else {
                KNBKLogger.debug("KNBKPeripheral#timeoutConnection: expired")
            }
        }
    }
    
    private func discoverIfConnected(services:[CBUUID]!) {
        if self.state == .Connected {
            self.cbPeripheral.discoverServices(services)
        } else {
            self.servicesDiscoveredPromise.failure(KNBKError.peripheralDisconnected)
        }
    }
    
    private func clearAll() {
        self.discoveredServices.removeAll()
        self.discoveredCharacteristics.removeAll()
    }
    
    internal func didDisconnectPeripheral() {
        KNBKLogger.debug("KNBKPeripheral#didDisconnectPeripheral")
        self._disconnectedAt = NSDate()
        if let connectorator = self._connectorator {
            if (self.forcedDisconnect) {
                self.forcedDisconnect = false
                KNBKLogger.debug("KNBKPeripheral#didDisconnectPeripheral: forced disconnect")
                connectorator.didForceDisconnect()
            } else {
                switch(self.currentError) {
                case .None:
                    KNBKLogger.debug("KNBKPeripheral#didDisconnectPeripheral: No errors disconnecting")
                    connectorator.didDisconnect()
                case .Timeout:
                    KNBKLogger.debug("KNBKPeripheral#didDisconnectPeripheral: Timeout reconnecting")
                    connectorator.didTimeout()
                }
            }
        }
    }

    internal func didConnectPeripheral() {
        KNBKLogger.debug("PeripheralConnectionError#didConnectPeripheral")
        self._connectedAt = NSDate()
        self._connectorator?.didConnect(self)
    }
    
    internal func didFailToConnectPeripheral(error:NSError?) {
        KNBKLogger.debug("PeripheralConnectionError#didFailToConnectPeripheral")
        self._connectorator?.didFailConnect(error)
    }
    
    internal func discoverService(head:KNBKService, tail:[KNBKService], promise:KNBKPromise<[KNBKService]>) {
        let discoveryFuture = head.discoverAllCharacteristics()
        if tail.count > 0 {
            discoveryFuture.onSuccess {_ in
                self.discoverService(tail[0], tail:Array(tail[1..<tail.count]), promise:promise)
            }
        } else {
            discoveryFuture.onSuccess {_ in
                promise.success(self.services)
            }
        }
        discoveryFuture.onFailure {error in
            promise.failure(error)
        }
    }
}
