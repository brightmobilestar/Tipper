//
//  KNAPIResponse.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 11/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

struct KNAPIResponse {
    var status: String! = ""
    let dataObject : AnyObject?
    let hasErrors: Bool = false
    let numberOfErrors:Int = 0
    //array with API errors
    let errors = [APIError]()
    
    //initializer
    init(){
        self.hasErrors = true
        
    }
    init(fromJsonObject json:NSDictionary){
        if (json["status"] != nil) {
            //if(!self.status.isEmpty){
            self.status=json["status"] as NSString
            if self.status  == "error"{
                self.hasErrors = true
                if let errorsNode:NSArray = json["errors"] as? NSArray{
                    numberOfErrors = errorsNode.count
                    //process the errors
                    for var index = 0; index < errorsNode.count; ++index{
                        let apiError = APIError(errorNode: errorsNode[index] as NSDictionary)
                        errors.append(apiError)
                    }
                }
            }
            else{
                self.dataObject = json["data"] as AnyObject!
            }
        }
    }
    
    
    // MARK -- APIError structure
    struct APIError {
        let parameter: String
        let errorCode: String
        let errorMessage: String
        
        //MARK initialize
        init(errorNode errorObject: NSDictionary){
            self.parameter = errorObject["param"] as NSString
            self.errorCode = errorObject["code"] as NSString
            self.errorMessage = errorObject["message"] as NSString
        }
    }
    
    
}


    