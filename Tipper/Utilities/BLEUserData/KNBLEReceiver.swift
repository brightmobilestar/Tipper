//
//  KNBLEReceiver.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit
import Foundation

import CoreBluetooth

@objc protocol KNBLEReceiverDelegate : NSObjectProtocol {
    
    func receiver(receiver: KNBLEReceiver, didFindUserStringData userString: String)
    func receiver(receiver: KNBLEReceiver, didFindUserDictionaryData userDictionary: Dictionary<String,String>)
    optional func receiver(receiver: KNBLEReceiver, didFailError error: NSError?)
    optional func receiver(receiver: KNBLEReceiver, powerStateChanged on: Bool)
}



class KNBLEReceiver: NSObject, KNBKCentralManagerDelegate {
    
    weak var delegate : KNBLEReceiverDelegate?
    
    var powerState : Bool = false
    
    class var sharedInstance: KNBLEReceiver
    {
        struct Singleton
        {
            static let instance = KNBLEReceiver()
        }
        
        KNBKCentralManager.sharedInstance.delegate = Singleton.instance
        
        return Singleton.instance
    }
    
    // MARK: Export
    
    func startScanning()
    {
        // Power on
        
        KNBKCentralManager.sharedInstance.disconnectAllPeripherals()
        KNBKCentralManager.sharedInstance.removeAllPeripherals()
        
        KNBKCentralManager.sharedInstance.powerOn().onSuccess{
            
            let toFindServices: Array<CBUUID> = [kBLEUserInfoServiceUUID]
            
            // Block when find peripheral
            let afterPeripheralDiscovered = {(discovery:KNBKPeripheralDiscovery) -> Void in
                
                
                let peripheral : KNBKPeripheral = discovery.peripheral
                
                // Set parameters of connection process
                let connectorator = KNBKConnectorator(capacity:kBLEConnectCapacity) {config in
                    // Retry count when connection failed
                    config.timeoutRetries = kBLEMaximumReconnects
                    
                    config.connectionTimeout = kBLEPeripheralConnectTimeout
                    config.characteristicTimeout = kBLECharacterisiticReadWriteTimeout
                }
                
                let connectoratorFuture = connectorator.onConnect()
                connectoratorFuture.onSuccess {_ in
                    KNBKLogger.debug("Connectorator#connect")
                    let servicesDiscoverFuture = peripheral.discoverAllServices()
                    
                    servicesDiscoverFuture.onSuccess{ services in
                        if ( peripheral.services.count > 0 ){
                            // Found service, should find characteristics
                            
                            for service in peripheral.services{
                                
                                KNBKLogger.debug("detected service------->\(service.uuid)")
                                
                                if service.uuid.UUIDString.isEqual(kBLEUserInfoServiceUUID.UUIDString){
                                    
                                    let characteristicDiscoverFuture = service.discoverAllCharacteristics()
                                    
                                    characteristicDiscoverFuture.onSuccess{ characteristics in
                                        // if there is characteristic, check uuid and then read value,
                                        for characteristic : KNBKCharacteristic in service.characteristics{
                                            // if uuid is same
                                            if ( characteristic.uuid.UUIDString.isEqual(kBLEUserStringDataCharacteristicUUID.UUIDString) ){
                                                // read data from characteristic
                                                let dataReadFuture = characteristic.read()
                                                
                                                // when succeed to read data
                                                dataReadFuture.onSuccess{_ in
                                                    // if there is data, trigger delegate to find user.
                                                    if characteristic.value != nil {
                                                        if self.delegate != nil {
                                                            let userStringData : String = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
                                                            if ( self.delegate != nil ){
                                                                self.delegate?.receiver(self, didFindUserStringData: userStringData)
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                                
                                                dataReadFuture.onFailure{ error in
                                                    if self.delegate != nil{
                                                        self.delegate!.receiver?(self, didFailError: error)
                                                    }
                                                }
                                            }
                                            
                                            if ( characteristic.uuid.UUIDString.isEqual(kBLEUserDictionaryDataCharacteristicUUID.UUIDString) ){
                                                // read data from characteristic
                                                let dataReadFuture = characteristic.read()
                                                
                                                // when succeed to read data
                                                dataReadFuture.onSuccess{_ in
                                                    // if there is data, trigger delegate to find user.
                                                    if characteristic.value != nil {
                                                        if self.delegate != nil {
                                                            println("\(characteristic.value.length)")
                                                            let dictionary:Dictionary<String,String> = NSJSONSerialization.JSONObjectWithData(characteristic.value!, options: nil, error: nil) as Dictionary<String,String>
                                                            
                                                            if ( self.delegate != nil ){
                                                                self.delegate?.receiver(self, didFindUserDictionaryData: dictionary)
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                                
                                                dataReadFuture.onFailure{ error in
                                                    if self.delegate != nil{
                                                        self.delegate!.receiver?(self, didFailError: error)
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    characteristicDiscoverFuture.onFailure{ error in
                                        if self.delegate != nil{
                                            self.delegate!.receiver?(self, didFailError: error)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    servicesDiscoverFuture.onFailure{ error in
                        if self.delegate != nil{
                            self.delegate!.receiver?(self, didFailError: error)
                        }
                    }
                }
                
                connectoratorFuture.onFailure {error in
                    if error.domain == KNBKError.domain {
                        if let connectoratorError = KNBKConnectoratorError(rawValue:error.code) {
                            switch connectoratorError {
                            case .Timeout:
                                // Connection tieout
                                KNBKLogger.debug("Connectorator#Timeout: '\(peripheral.name)'")
                                peripheral.reconnect()
                                break;
                            case .Disconnect:
                                // Disconnected
                                KNBKLogger.debug("Connectorator#Disconnect")
                                peripheral.reconnect()
                                break;
                            case .ForceDisconnect:
                                // Forcced disconnect
                                KNBKLogger.debug("Connectorator#ForcedDisconnect")
                                break;
                            case .Failed:
                                // Failed to connect
                                KNBKLogger.debug("Connectorator#Failed")
                                break;
                            case .GiveUp:
                                // Giveup connection
                                KNBKLogger.debug("Connectorator#GiveUp: '\(peripheral.name)'")
                                peripheral.terminate()
                                break;
                            }
                            
                            if self.delegate != nil{
                                self.delegate!.receiver?(self, didFailError: error)
                            }
                        } else {
                            if self.delegate != nil{
                                self.delegate!.receiver?(self, didFailError: error)
                            }
                        }
                    } else {
                        if self.delegate != nil{
                            self.delegate!.receiver?(self, didFailError: error)
                        }
                    }
                    
                }
                
                peripheral.connect(connectorator:connectorator)
            }
            
            
            let afterTimeout = {(error:NSError) -> Void in
                if error.domain == KNBKError.domain && error.code == KNBKPeripheralError.DiscoveryTimeout.rawValue {
                    KNBKLogger.debug("Scannerator#timeoutScan: timing out")
                    KNBKTimedScannerator.sharedInstance.stopScanning()
                }
            }
            
            
            var future : KNBKFutureStream<KNBKPeripheralDiscovery>
            
            future = KNBKCentralManager.sharedInstance.startScanning(capacity:30) // startScanningForServiceUUIDs(toFindServices, capacity:kBLEConnectCapacity)
            
            future.onSuccess(afterPeripheralDiscovered)
            future.onFailure(afterTimeout)
            
    
        }
        
        
    }
    
    func isPowerOn() -> Bool{
        return KNBKCentralManager.sharedInstance.poweredOn ? true : false
    }
    
    func stopScanning()
    {
        if KNBKCentralManager.sharedInstance.isScanning {
            KNBKCentralManager.sharedInstance.stopScanning()
        }
        KNBKCentralManager.sharedInstance.disconnectAllPeripherals()
        KNBKCentralManager.sharedInstance.removeAllPeripherals()
        KNBKCentralManager.sharedInstance.powerOff()
        KNBKCentralManager.sharedInstance.resetCentral()
    }
    
    
    func centralManager(centralManager: KNBKCentralManager, powerStateChanged on: Bool) {
        if ( powerState != on ){
            powerState = on
            if (self.delegate?.respondsToSelector(Selector("finder:powerStateChanged:")) != nil) {
                self.delegate?.receiver?(self, powerStateChanged: on)
            }
            
        }
        
    }
    
}
