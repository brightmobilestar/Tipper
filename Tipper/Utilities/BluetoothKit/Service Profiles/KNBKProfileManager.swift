//
//  KNBKProfileManager.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKProfileManager {
    
    // INTERNAL
    internal var serviceProfiles = Dictionary<CBUUID, KNBKServiceProfile>()
    
    // PRIVATE
    private init() {
    }
    
    // PUBLIC
    public var services : [KNBKServiceProfile] {
        return self.serviceProfiles.values.array
    }
    
    public class var sharedInstance : KNBKProfileManager {
        struct Static {
            static let instance = KNBKProfileManager()
        }
        return Static.instance
    }
    
    public func addService(serviceProfile:KNBKServiceProfile) -> KNBKServiceProfile {
        KNBKLogger.debug("KNBKProfileManager#createServiceProfile: name=\(serviceProfile.name), uuid=\(serviceProfile.uuid.UUIDString)")
        self.serviceProfiles[serviceProfile.uuid] = serviceProfile
        return serviceProfile
    }
    
    public func service(uuid:CBUUID) -> KNBKServiceProfile? {
        return self.serviceProfiles[uuid]
    }

}
