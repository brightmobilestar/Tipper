//
//  KNBKService.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKService : NSObject {
    
    private let profile                             : KNBKServiceProfile?
    private var characteristicsDiscoveredPromise    = KNBKPromise<[KNBKCharacteristic]>()

    internal let _peripheral                        : KNBKPeripheral
    internal let cbService                          : CBService
    
    internal var discoveredCharacteristics      = Dictionary<CBUUID, KNBKCharacteristic>()
    
    public var name : String {
        if let profile = self.profile {
            return profile.name
        } else {
            return "Unknown"
        }
    }
    
    public var uuid : CBUUID! {
        return self.cbService.UUID
    }
    
    public var characteristics : [KNBKCharacteristic] {
        return self.discoveredCharacteristics.values.array
    }
    
    public var peripheral : KNBKPeripheral {
        return self._peripheral
    }
    
    public func discoverAllCharacteristics() -> KNBKFuture<[KNBKCharacteristic]> {
        KNBKLogger.debug("KNBKService#discoverAllCharacteristics")
        return self.discoverIfConnected(nil)
    }

    public func discoverCharacteristics(characteristics:[CBUUID]) -> KNBKFuture<[KNBKCharacteristic]> {
        KNBKLogger.debug("KNBKService#discoverCharacteristics")
        return self.discoverIfConnected(characteristics)
    }

    private func discoverIfConnected(services:[CBUUID]!) -> KNBKFuture<[KNBKCharacteristic]> {
        self.characteristicsDiscoveredPromise = KNBKPromise<[KNBKCharacteristic]>()
        if self.peripheral.state == .Connected {
            self.peripheral.cbPeripheral.discoverCharacteristics(nil, forService:self.cbService)
        } else {
            self.characteristicsDiscoveredPromise.failure(KNBKError.peripheralDisconnected)
        }
        return self.characteristicsDiscoveredPromise.future
    }

    internal init(cbService:CBService, peripheral:KNBKPeripheral) {
        self.cbService = cbService
        self._peripheral = peripheral
        self.profile = KNBKProfileManager.sharedInstance.serviceProfiles[cbService.UUID]
    }
    
    internal func didDiscoverCharacteristics(error:NSError!) {
        if let error = error {
            self.characteristicsDiscoveredPromise.failure(error)
        } else {
            self.discoveredCharacteristics.removeAll()
            if let cbCharacteristics = self.cbService.characteristics {
                for cbCharacteristic : AnyObject in cbCharacteristics {
                    let bcCharacteristic = KNBKCharacteristic(cbCharacteristic:cbCharacteristic as CBCharacteristic, service:self)
                    self.discoveredCharacteristics[bcCharacteristic.uuid] = bcCharacteristic
                    bcCharacteristic.didDiscover()
                    KNBKLogger.debug("KNBKService#didDiscoverCharacteristics: uuid=\(bcCharacteristic.uuid.UUIDString), name=\(bcCharacteristic.name)")
                }
                self.characteristicsDiscoveredPromise.success(self.characteristics)
            }
        }
    }
}