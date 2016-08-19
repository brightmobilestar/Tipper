//
//  KNEmailExistResponse.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 12/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation


struct KNEmailExistResponse {
    
    
    var userId: String
    var avatar:String?
    var email: String
    var publicName: String
    var pendingRegistration:Bool
    var mobileNumber:String?
    var countryCode:String?
    var password:String?
    
    //Added by luokey
    var paypalEmail:String?
    
    
    //to create a void object
    init(){
        userId = ""
        avatar = ""
        email = ""
        countryCode = ""
        publicName = ""
        
        //Added by luokey
        paypalEmail = ""
        
        self.pendingRegistration = false
    }
    
    init(email:String, pendingRegistration:Bool){
        userId = ""
        avatar = ""
         countryCode = ""
        self.email = email
        publicName = ""
        
        //Added by luokey
        paypalEmail = ""
        
        self.pendingRegistration = pendingRegistration
    }
    
    
    
    //used from existEmail result
    init(dataObject:NSDictionary )
    {
       
        if(dataObject.objectForKey("avatar") != nil) {
            avatar = dataObject.objectForKey("avatar") as String!
        }
        
        if(dataObject.objectForKey("id") != nil) {
           userId = dataObject.objectForKey("id") as String!
        }
        else{
            userId = ""
        }
        
        if(dataObject.objectForKey("email") != nil) {
            email = dataObject.objectForKey("email") as String!
        }
        else{
            email = ""
        }
        if(dataObject.objectForKey("publicName") != nil) {
            publicName = dataObject.objectForKey("publicName") as String!
        }
        else{
            publicName = ""
        }
        
        
        // Added by luokey
        if(dataObject.objectForKey("paypalEmail") != nil) {
            paypalEmail = dataObject.objectForKey("paypalEmail") as String!
        }
        else{
            paypalEmail = ""
        }
        
        self.pendingRegistration = false
    }
    
   
    
}

