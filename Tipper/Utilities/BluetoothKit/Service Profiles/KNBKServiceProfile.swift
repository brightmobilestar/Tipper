//
//  KNBKServiceProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKServiceProfile {
    
    // INTERNAL
    internal var characteristicProfiles = Dictionary<CBUUID, KNBKCharacteristicProfile>()

    // PUBLIC
    public let uuid : CBUUID
    public let name : String
    public var tag  = "Miscellaneous"
    
    public var characteristics : [KNBKCharacteristicProfile] {
        return self.characteristicProfiles.values.array
    }
    
    public init(uuid:CBUUID, name:String, profile:(service:KNBKServiceProfile) -> ()) {
        self.name = name
        self.uuid = uuid
        profile(service:self)
    }
    
    public init(uuid:String, name:String, profile:(service:KNBKServiceProfile) -> ()) {
        self.name = name
        self.uuid = CBUUID(string:uuid)
        profile(service:self)
    }
    
    public func addCharacteristic( characteristicProfile:KNBKCharacteristicProfile) {
        KNBKLogger.debug("KNBKServiceProfile#createCharateristic: name=\(characteristicProfile.name), uuid=\(characteristicProfile.uuid.UUIDString)")
        self.characteristicProfiles[characteristicProfile.uuid] = characteristicProfile
    }
    
}