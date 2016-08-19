//
//  KNBLETransmitter.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit

@objc protocol KNBLETransmitterDelegate : NSObjectProtocol {
    
    optional func transmitter(transmitter: KNBLETransmitter, powerStateChanged on: Bool)
}

class KNBLETransmitter: NSObject, KNBKPeripheralManagerDelegate {
   
    var initedService : Bool = false
    var powerState : Bool = false
    
    weak var delegate : KNBLETransmitterDelegate!
    
    class var sharedInstance: KNBLETransmitter
    {
        struct Singleton
        {
            static let instance = KNBLETransmitter()
            
        }
        
        KNBKPeripheralManager.sharedInstance.delegate = Singleton.instance
        
        return Singleton.instance
    }
    
    //MARK: Export
    func initService(userStringData : String?, userDictionaryData: Dictionary<String,String>?){
        
        if initedService == true {
            return
        }
        
        KNBLEUserInfoServiceProfile.create(userStringData, userDictionaryData: userDictionaryData)
        
        if KNBKProfileManager.sharedInstance.serviceProfiles.count > 0 {
            
            let serviceProfile = KNBKProfileManager.sharedInstance.services[0]
            
            let service = KNBKMutableService(profile:serviceProfile)
            
            service.characteristicsFromProfiles(serviceProfile.characteristics)
            let future = KNBKPeripheralManager.sharedInstance.addService(service)
            future.onSuccess {
                self.initedService = true
            }
            future.onFailure{ error in
                KNBKLogger.debug("\(error.localizedDescription)")
            }
        }
        
    }
    
    func turnOn(on: Bool){
        if on {
            KNBKPeripheralManager.sharedInstance.powerOn()
            KNBKPeripheralManager.sharedInstance.startAdvertising(kBLEUserInfoServiceName)
        }
        else{
            KNBKPeripheralManager.sharedInstance.stopAdvertising()
            KNBKPeripheralManager.sharedInstance.powerOff()
        }
    }
    
    func isPowerOn() -> Bool{
        return KNBKPeripheralManager.sharedInstance.isPoweredOn
    }
    
    //MARK: KNBLEBroadcasterDelegate
    func peripheralManager(peripheralManager: KNBKPeripheralManager, powerStateChanged on: Bool) {
        if powerState != on {
            powerState = on;
            if self.delegate != nil  {
                if self.delegate.respondsToSelector(Selector("transmitter:powerStateChanged:")) {
                    self.delegate!.transmitter!(self, powerStateChanged: on)
                }
            }
        }
        
    }
    
}
