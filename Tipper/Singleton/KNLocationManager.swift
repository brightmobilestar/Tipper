//
//  KNLocationManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class KNLocationManager : NSObject, CLLocationManagerDelegate  {
    
    class var sharedInstance : KNLocationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNLocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNLocationManager()
        }
        return Static.instance!
    }
    
    let locationManager: CLLocationManager
    
    override init() {
        self.locationManager = CLLocationManager()
      
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        
        self.locationManager.requestWhenInUseAuthorization()
        requestWhenInUseAuthorization()
    }
    
    func requestWhenInUseAuthorization(){
        if UIApplication.sharedApplication().respondsToSelector("requestWhenInUseAuthorization:"){
            //ioS8+
            let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.NotDetermined  {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
        }
        else{
            //iOS < 8
            let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.NotDetermined  {
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    
    func startLocationUpdates(){
        self.locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates(){
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    //MARK locationManager delegates
   
    
    func  locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            
            if KNMobileUserManager.sharedInstance.hasSavedUser(){
                KNMobileUserManager.sharedInstance.updateUserLocationManagerSettings(true, completed: { (success, responseObj) -> () in
                    
                })
            }
                startLocationUpdates()
        }
        else{
            if KNMobileUserManager.sharedInstance.hasSavedUser(){
                KNMobileUserManager.sharedInstance.updateUserLocationManagerSettings(false, completed: { (success, responseObj) -> () in
                    
                })
            }
        }
    }

    func  locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        if (oldLocation != nil){
            if (newLocation != oldLocation){
                
                var latString = "\(newLocation.coordinate.latitude)"
                var lonString = "\(newLocation.coordinate.longitude)"
                
                
                KNAPIManager.sharedInstance.updateUserLocation(Coordinates: latString, longitude: lonString, completed: { (success, responseObj) -> () in
                    
                    //After first update change logic to significant changes to save power
                     self.locationManager.stopUpdatingLocation()
                     self.locationManager.startMonitoringSignificantLocationChanges()
                })
            }
        }
       
    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
}
