//
//  KNBKMutableService.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKMutableService : NSObject {
    
    private let profile             : KNBKServiceProfile!
    private var _characteristics    : [KNBKMutableCharacteristic] = []

    internal let cbMutableService   : CBMutableService!

    public var uuid : CBUUID {
        return self.profile.uuid
    }
    
    public var name : String {
        return self.profile.name
    }
    
    public var characteristics : [KNBKMutableCharacteristic] {
        get {
            return self._characteristics
        }
        set {
            self._characteristics = newValue
            self.cbMutableService.characteristics = self._characteristics.reduce(Array<CBMutableCharacteristic>()) {(cbCharacteristics, characteristic) in
                                                            KNBKPeripheralManager.sharedInstance.configuredCharcteristics[characteristic.cbMutableChracteristic] = characteristic
                                                            return cbCharacteristics + [characteristic.cbMutableChracteristic]
                                                        }
        }
    }
    
    public init(profile:KNBKServiceProfile) {
        super.init()
        self.profile = profile
        self.cbMutableService = CBMutableService(type:self.profile.uuid, primary:true)
    }
    
    public func characteristicsFromProfiles(profiles:[KNBKCharacteristicProfile]) {
        self.characteristics = profiles.map{KNBKMutableCharacteristic(profile:$0)}
    }
    
}