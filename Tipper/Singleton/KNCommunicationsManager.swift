//
//  KNCommunicationsManager.swift
//  CloudBeacon
//
//  Created by Peter van de Put on 24/10/14.
//  Copyright (c) 2014 Knodeit LLC. All rights reserved.
//
/*
Purpose: Provides singleton access for communication with API's


*/
import Foundation
import UIKit

class KNCommunicationsManager {
    
    typealias Params = Dictionary<String, AnyObject>
    
    class var sharedInstance : KNCommunicationsManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNCommunicationsManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNCommunicationsManager()
        }
        return Static.instance!
    }
    
    //MARK: Helpers
    
    func postAndReturnDictionaryWithoutParameters(url : String,postCompleted : (success: Bool,apiResponse:KNAPIResponse) -> ()) {
        
        if(KNReachability.isConnectedToNetwork() == true) {
            var request = NSMutableURLRequest(URL: NSURL(string: url)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            var err: NSError?
            //add the post parameters
        
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            //create the task
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if let httpResponse = response as? NSHTTPURLResponse{
                    //get the status code
                    var statusCode:Int  = httpResponse.statusCode
                    if (statusCode == 200){
                        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        var err: NSError?
                        var json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &err) as? NSDictionary
                        //println("JSON \(json)")
                        let apiResponse = KNAPIResponse(fromJsonObject:json!)
                        postCompleted(success: statusCode==200, apiResponse:apiResponse)
                    }
                    else {
                        let apiResponse = KNAPIResponse(fromJsonObject: self.getHttpStatusError(statusCode))
                        postCompleted(success: false, apiResponse: apiResponse)
                    }
                    
                }
                else{
                    let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
                    postCompleted(success: false,apiResponse:apiResponse)
                }
                
            })
            task.resume()
        }
        else {
            var error:NSError = NSError(domain: "", code:NSURLErrorNotConnectedToInternet , userInfo: nil)
            let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
            postCompleted(success: false,apiResponse:apiResponse)
        }
    }
    
    
    
    
    
    func postAndReturnDictionary(params : Params, url : String,postCompleted : (success: Bool,apiResponse:KNAPIResponse) -> ()) {
        
        if(KNReachability.isConnectedToNetwork() == true) {
            var request = NSMutableURLRequest(URL: NSURL(string: url)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            var err: NSError?
            //add the post parameters
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            //create the task
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if let httpResponse = response as? NSHTTPURLResponse{
                    //get the status code
                    var statusCode:Int  = httpResponse.statusCode
                    if (statusCode == 200){
                        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        var err: NSError?
                        var json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &err) as? NSDictionary
                       
                        if (json != nil){
                            let apiResponse = KNAPIResponse(fromJsonObject:json!)
                            postCompleted(success: statusCode==200, apiResponse:apiResponse)
                        }
                        else{
                            let apiResponse = KNAPIResponse()
                            postCompleted(success: statusCode==200, apiResponse:apiResponse)
                        }
                        
                        
                    }
                    else {
                        let apiResponse = KNAPIResponse(fromJsonObject: self.getHttpStatusError(statusCode))
                        postCompleted(success: false, apiResponse: apiResponse)
                    }
                    
                }
                else{
                    let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
                    postCompleted(success: false,apiResponse:apiResponse)
                }
                
            })
            task.resume()
        }
        else {
            var error:NSError = NSError(domain: "", code:NSURLErrorNotConnectedToInternet , userInfo: nil)
            let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
            postCompleted(success: false,apiResponse:apiResponse)
        }
    }
    
    func postMultipartAndReturnDictionary(params : Dictionary<String, AnyObject>, url : String,postCompleted : (success: Bool,apiResponse:KNAPIResponse) -> ()) {
        
        if(KNReachability.isConnectedToNetwork() == true) {
            var request = NSMutableURLRequest(URL: NSURL(string: url)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            var boundary:String = "THIS_IS_BOUNDARY_STRING";
            var contentType:String = "multipart/form-data; boundary=\(boundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            
            var body:NSMutableData = NSMutableData()//[NSMutableData data];
            
            var err: NSError?
            
            //add the post parameters
            let dataValue = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)!
            
            for (key, value : AnyObject) in params {
                
                body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                
                if NSJSONSerialization.isValidJSONObject(value) {
                    
                    var err: NSError?
                    var sValue = NSJSONSerialization.dataWithJSONObject(value, options: nil, error: &err)
                    
                    if err == nil {
                        
                        body.appendData(sValue!)
                    }else{
                        
                        body.appendData("\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
                    }
                }else{
                    
                    body.appendData("\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
                }
                
            }
            
            body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            
            request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
            request.HTTPBody = body
            
            //create the task
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if let httpResponse = response as? NSHTTPURLResponse{
                    //get the status code
                    var statusCode:Int  = httpResponse.statusCode
                    if (statusCode == 200){
                        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                        var err: NSError?
                        var json = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(0), error: &err) as? NSDictionary
                        
                        let apiResponse = KNAPIResponse(fromJsonObject:json!)
                        postCompleted(success: statusCode==200, apiResponse: apiResponse)
                    }
                    else{
                        let apiResponse = KNAPIResponse()
                        postCompleted(success: false,apiResponse:apiResponse)
                    }
                    
                }
                else {
                    
                    //let apiResponse = KNAPIResponse()
                    let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
                    postCompleted(success: false,apiResponse:apiResponse)
                }
                
            })
            task.resume()
        }
        else {
            var error:NSError = NSError(domain: "", code:NSURLErrorNotConnectedToInternet , userInfo: nil)
            let apiResponse = KNAPIResponse(fromJsonObject: self.getNetworkError(error))
            postCompleted(success: false,apiResponse:apiResponse)
        }
    }

    
    //MARK Get http common errors
    func getHttpStatusError(code: Int) -> NSDictionary {
        var errorMessage:String = ""
        switch code {
        case 400:
            errorMessage = NSLocalizedString("Bad Request.", comment: "")
        case 401:
            errorMessage = NSLocalizedString("Unauthorized.", comment: "")
        case 403:
            errorMessage = NSLocalizedString("Forbidden.", comment: "")
        case 404:
            errorMessage = NSLocalizedString("Not Found.", comment: "")
        case 408:
            errorMessage = NSLocalizedString("Request Timeout.", comment: "")
        case 500:
            errorMessage = NSLocalizedString("Internal Server Error.", comment: "")
        case 502:
            errorMessage = NSLocalizedString("Bad Gateway.", comment: "")
        case 503:
            errorMessage = NSLocalizedString("Service Unavailable.", comment: "")
        default:
            errorMessage = NSLocalizedString("Something went wrong.", comment: "")
        }
        
        let errorDict:NSArray = [["code": "\(code)", "message": errorMessage, "param": ""]]
        let errorResponse: NSDictionary = ["status": "error", "errors": errorDict]
        return errorResponse
    }
    
    //MARK Get network errors
    func getNetworkError(error: NSError) -> NSDictionary {
        var errorMessage:String = ""
        switch error.code {
        case NSURLErrorUnknown:
            errorMessage = NSLocalizedString("An unknown error occurred.", comment: "")
        case NSURLErrorCancelled:
            errorMessage = NSLocalizedString("The connection was cancelled.", comment: "")
        case NSURLErrorBadURL:
            errorMessage = NSLocalizedString("The connection failed due to a malformed URL.", comment: "")
        case NSURLErrorTimedOut:
            errorMessage = NSLocalizedString("The connection timed out.", comment: "")
        case NSURLErrorUnsupportedURL:
            errorMessage = NSLocalizedString("The connection failed due to an unsupported URL scheme.", comment: "")
        case NSURLErrorCannotFindHost:
            errorMessage = NSLocalizedString("The connection failed because the host could not be found.", comment: "")
        case NSURLErrorCannotConnectToHost:
            errorMessage = NSLocalizedString("The connection failed because a connection cannot be made to the host.", comment: "")
        case NSURLErrorNetworkConnectionLost:
            errorMessage = NSLocalizedString("The connection failed because the network connection was lost.", comment: "")
        case NSURLErrorDNSLookupFailed:
            errorMessage = NSLocalizedString("The connection failed because the DNS lookup failed.", comment: "")
        case NSURLErrorHTTPTooManyRedirects:
            errorMessage = NSLocalizedString("The HTTP connection failed due to too many redirects.", comment: "")
        case NSURLErrorResourceUnavailable:
            errorMessage = NSLocalizedString("The connection’s resource is unavailable.", comment: "")
        case NSURLErrorNotConnectedToInternet:
            errorMessage = NSLocalizedString("Device is not connected to the internet.", comment: "")
        case NSURLErrorRedirectToNonExistentLocation:
            errorMessage = NSLocalizedString("The connection was redirected to a nonexistent location.", comment: "")
        case NSURLErrorBadServerResponse:
            errorMessage = NSLocalizedString("The connection received an invalid server response.", comment: "")
        case NSURLErrorUserCancelledAuthentication:
            errorMessage = NSLocalizedString("The connection failed because the user cancelled required authentication.", comment: "")
        case NSURLErrorUserAuthenticationRequired:
            errorMessage = NSLocalizedString("The connection failed because authentication is required.", comment: "")
        case NSURLErrorZeroByteResource:
            errorMessage = NSLocalizedString("The resource retrieved by the connection is zero bytes.", comment: "")
        case NSURLErrorCannotDecodeContentData:
            errorMessage = NSLocalizedString("The connection cannot decode data encoded with a known content encoding.", comment: "")
        case NSURLErrorCannotDecodeContentData:
            errorMessage = NSLocalizedString("The connection cannot decode data encoded with an unknown content encoding.", comment: "")
        case NSURLErrorCannotParseResponse:
            errorMessage = NSLocalizedString("The connection cannot parse the server’s response.", comment: "")
        case NSURLErrorInternationalRoamingOff:
            errorMessage = NSLocalizedString("The connection failed because international roaming is disabled on the device.", comment: "")
        case NSURLErrorCallIsActive:
            errorMessage = NSLocalizedString("The connection failed because a call is active.", comment: "")
            
        case NSURLErrorDataNotAllowed:
            errorMessage = NSLocalizedString("The connection failed because data use is currently not allowed on the device.", comment: "")
        case NSURLErrorRequestBodyStreamExhausted:
            errorMessage = NSLocalizedString("The connection failed because its request’s body stream was exhausted.", comment: "")
        default:
            errorMessage = NSLocalizedString("Something went wrong.", comment: "")
        }
        let errorDict:NSArray = [["code": "\(error.code)", "message": errorMessage, "param": ""]]
        let errorResponse: NSDictionary = ["status": "error", "errors": errorDict]
        return errorResponse
    }
    
}