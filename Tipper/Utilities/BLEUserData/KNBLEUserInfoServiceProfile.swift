//
//  KNBLEUserIdServiceProfile.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit
import CoreBluetooth

public struct KNBLEATT {
    
    struct UserInfoService {
        static let uuid = kBLEUserInfoServiceUUID
        static let name = kBLEUserInfoServiceName
        struct UserStringData{
            static let uuid = kBLEUserStringDataCharacteristicUUID
            static let name = kBLEUserStringDataCharacteristicName
        }
        struct UserDictionaryData{
            static let uuid = kBLEUserDictionaryDataCharacteristicUUID
            static let name = kBLEUserDictionaryDataCharacteristicName
        }
    }
}


public class KNBLEUserInfoServiceProfile{
    public class func create (userStringData: String?, userDictionaryData: Dictionary<String, String>?) {
        
        let profileManager = KNBKProfileManager.sharedInstance
        
        profileManager.addService(KNBKServiceProfile(uuid:KNBLEATT.UserInfoService.uuid, name: KNBLEATT.UserInfoService.name){(serviceProfile) in
            serviceProfile.tag = "KNBLEATT"
            serviceProfile.addCharacteristic(KNBKStringCharacteristicProfile(uuid:KNBLEATT.UserInfoService.UserStringData.uuid, name:KNBLEATT.UserInfoService.UserStringData.name)
                {(characteristicProfile:KNBKStringCharacteristicProfile) in
                    characteristicProfile.properties = CBCharacteristicProperties.Read
                    if ( userStringData != nil ){
                        characteristicProfile.initialValue = userStringData!.dataUsingEncoding(NSUTF8StringEncoding)
                    }
                    else{
                        characteristicProfile.initialValue = nil
                    }
                })
            
            serviceProfile.addCharacteristic(KNBKStringCharacteristicProfile(uuid:KNBLEATT.UserInfoService.UserDictionaryData.uuid, name:KNBLEATT.UserInfoService.UserDictionaryData.name)
                {(characteristicProfile:KNBKStringCharacteristicProfile) in
                    
                    if userDictionaryData == nil {
                        characteristicProfile.properties = CBCharacteristicProperties.Read
                        characteristicProfile.initialValue = nil
                    }
                    else{
                        
                        characteristicProfile.properties = CBCharacteristicProperties.Read
                        characteristicProfile.initialValue = NSJSONSerialization.dataWithJSONObject(userDictionaryData!, options: nil, error: nil)
                    }
                    
                })
        })
    }
}

