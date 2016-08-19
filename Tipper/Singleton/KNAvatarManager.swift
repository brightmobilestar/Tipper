//
//  KNAvatarManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 12/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation



class KNAvatarManager: NSObject {
    
    
    class var sharedInstance : KNAvatarManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNAvatarManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNAvatarManager()
        }
        return Static.instance!
    }
    
    //MARK UploadAvatar from local image to target S3 Bucket using the KNS3BucketManager
    func uploadAvatar(avatarName name:String, publicRead:Bool? = false,  uploadProgress: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void)?,  uploadComplete:((uploadSuccessful: Bool, errorDescription: String) -> Void)!){
        // Upload avatar image
        let newImageFile = NSHomeDirectory().stringByAppendingPathComponent("/Documents/\(kNewAvatarImageName).jpg")
        
        if NSFileManager.defaultManager().fileExistsAtPath(newImageFile) == false {
            
            uploadComplete(uploadSuccessful: false, errorDescription: "Avatar image not found")
            return
        }
        
        
        //Create a local copy
        let localAvatarFile = NSHomeDirectory().stringByAppendingPathComponent("/Documents/\(name).jpg")
       
        var error: NSError?
        NSFileManager.defaultManager().copyItemAtPath(newImageFile, toPath: localAvatarFile, error: &error)
        
        
        let imageFileURL = NSURL(fileURLWithPath: newImageFile)
        let bucketAvatarName = name
        
        KNS3BucketManager.sharedInstance.uploadFile(fromLocalFileURL: imageFileURL!, toFilePathInBucket: bucketAvatarName, publicRead:publicRead, uploadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                  
                    uploadProgress! (bytesSent:bytesSent,totalBytesSent:totalBytesSent,totalBytesExpectedToSend:totalBytesExpectedToSend )
            
            },
            
            
                uploadComplete: { (uploadSuccessful, errorDescription) -> Void in
                
                if  uploadSuccessful {
                    uploadComplete(uploadSuccessful: true, errorDescription: "")
                }
                else {
                    uploadComplete(uploadSuccessful: false, errorDescription: errorDescription)
                }
        })
    }
    
    func uploadAvatar(avatarPath pathToLocalImage:String, avatarName name:String, publicRead:Bool? = false, uploadProgress: ((bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void)?,  uploadComplete:((uploadSuccessful: Bool, errorDescription: String) -> Void)!){
       
        
        if NSFileManager.defaultManager().fileExistsAtPath(pathToLocalImage) == false {
            
            uploadComplete(uploadSuccessful: false, errorDescription: "Avatar image not found")
            return
        }
       
        let imageFileURL = NSURL(fileURLWithPath: pathToLocalImage)
        let bucketAvatarName = name
        
        
        KNS3BucketManager.sharedInstance.uploadFile(fromLocalFileURL: imageFileURL!, toFilePathInBucket: bucketAvatarName,publicRead:publicRead, uploadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                uploadProgress! (bytesSent:bytesSent,totalBytesSent:totalBytesSent,totalBytesExpectedToSend:totalBytesExpectedToSend )

            }, uploadComplete: { (uploadSuccessful, errorDescription) -> Void in
                
                if  uploadSuccessful {
                    uploadComplete(uploadSuccessful: true, errorDescription: "")
                }
                else {
                    uploadComplete(uploadSuccessful: false, errorDescription: errorDescription)
                }
        })
    }
    
    func getAvatarImage(#placeholder:String, downloadComplete: ((downloadSuccessful: Bool, avatarImage: UIImage?, errorDescription: String) -> Void)!){
        
        // placeholder photo
        var returnedImage:UIImage?
        
        if let currentImageFilePath = self.currentUserAvatarFilePath()?{
            //do we have a local copy already
            if NSFileManager.defaultManager().fileExistsAtPath(currentImageFilePath) {
                returnedImage = UIImage(contentsOfFile: currentImageFilePath)
                downloadComplete(downloadSuccessful:true, avatarImage:returnedImage, errorDescription:"")
                
                return
            }
            else{
                //We need to download
                // Download avatar image
                
                var avatarURL:String =  KNMobileUserManager.sharedInstance.currentUser()!.avatar
               // if let  avatarURL:String =  KNMobileUserManager.sharedInstance.currentUser()?.avatar{
                    
                    println("avatarURL \(avatarURL)")
                if (!avatarURL.isEmpty){
                     println("avatarURL NO")
                }
                else{
                     println("avatarURL YES")
                }
                 if (!avatarURL.isEmpty){
                    var fileName:String = avatarURL.lastPathComponent
                    
                    let downloadImageFileURL = NSURL(fileURLWithPath:currentImageFilePath)
                    let bucketAvatarName = fileName
                    
                    KNS3BucketManager.sharedInstance.downloadFile(fromBucketFilePath: bucketAvatarName, toLocalFileURL: downloadImageFileURL!, downloadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                        
                        }) { (downloadSuccessful, errorDescription) -> Void in
                            
                            if  downloadSuccessful {
                                
                                returnedImage = UIImage(contentsOfFile: currentImageFilePath)
                                if  returnedImage != nil {
                                    
                                    downloadComplete(downloadSuccessful:true, avatarImage:returnedImage, errorDescription:"")
                                }else{
                                    
                                    // Remove error downloading file
                                    NSFileManager.defaultManager().removeItemAtPath(currentImageFilePath, error: nil)
                                    
                                    returnedImage = UIImage(named: placeholder)
                                    downloadComplete(downloadSuccessful:false, avatarImage:returnedImage, errorDescription:"")
                                }
                            }else {
                                
                                // Remove error downloading file
                                var error:NSError? = nil
                                NSFileManager.defaultManager().removeItemAtPath(currentImageFilePath, error: &error)
                                if  error != nil {
                                    
                                    
                                }
                                
                                returnedImage = UIImage(named: placeholder)
                                downloadComplete(downloadSuccessful:false, avatarImage:returnedImage, errorDescription:errorDescription)
                            }
                    }

                    
                }
                
                
                
                
                
            }
        }
        else{
            //use doesnt have avatar so return placeholder
            returnedImage = UIImage(named: placeholder)
            downloadComplete(downloadSuccessful:false, avatarImage:returnedImage, errorDescription:"")
            
            return
        }
        
       
        
        /*
        
        // Download avatar image
        let downloadImageFileURL = NSURL(fileURLWithPath:currentImageFile)
        let bucketAvatarName = self.avatar == nil ? "" : self.avatar!
        
        KNS3BucketManager.sharedInstance.downloadFile(fromBucketFilePath: bucketAvatarName, toLocalFileURL: downloadImageFileURL!, downloadProgress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            
            }) { (downloadSuccessful, errorDescription) -> Void in
                
                if  downloadSuccessful {
                    
                    returnedImage = UIImage(contentsOfFile: currentImageFile)
                    if  returnedImage != nil {
                        
                        downloadComplete(downloadSuccessful:true, avatarImage:returnedImage, errorDescription:"")
                    }else{
                        
                        // Remove error downloading file
                        NSFileManager.defaultManager().removeItemAtPath(currentImageFile, error: nil)
                        
                        returnedImage = UIImage(named: placeholder)
                        downloadComplete(downloadSuccessful:false, avatarImage:returnedImage, errorDescription:"")
                    }
                }else {
                    
                    // Remove error downloading file
                    var error:NSError? = nil
                    NSFileManager.defaultManager().removeItemAtPath(currentImageFile, error: &error)
                    if  error != nil {
                        
                        NSLog("Cannot delete current file")
                    }
                    
                    returnedImage = UIImage(named: placeholder)
                    downloadComplete(downloadSuccessful:false, avatarImage:returnedImage, errorDescription:errorDescription)
                }
        }
        */
    }
    

    
    func currentUserAvatarFilePath()->String? {
        
        if (KNMobileUserManager.sharedInstance.hasSavedUser()){
            var avatarURL:String = KNMobileUserManager.sharedInstance.currentUser()!.avatar
            if (!avatarURL.isEmpty){
                var fileName:String = avatarURL.lastPathComponent
                //return  NSHomeDirectory().stringByAppendingPathComponent("/Documents/\(kNewAvatarImageName)")
                println("fileName   \(fileName)")
                return  NSHomeDirectory().stringByAppendingPathComponent("/Documents/\(fileName)")
            }
            else{
                return ""
            }
        }
        else{
            return ""
        }
        
    }
    
    
    
    
    
    
    //MARK generate a unique filename based on the public name
    func createUniqueAvatarNameForUser(publicName:String) -> String{
        if publicName.isEmpty == false {
            var formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            var ret:String = formatter.stringFromDate(NSDate())
            var cleanedName =  publicName.stringByReplacingOccurrencesOfString(" ", withString: "", options: .CaseInsensitiveSearch, range: nil).lowercaseString
            return "\(cleanedName)_\(ret)_.jpg"
        }
        return ""
    }
    
}



