//
//  KNFileManager.swift
//  cbmvp
//
//  Created by PETRUS VAN DE PUT on 21/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import UIKit


class KNFileManager {
    
    class var sharedInstance : KNFileManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNFileManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNFileManager()
        }
        return Static.instance!
    }
    
    init() {
        createMediaDirectory()
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.knodeit.CloudBeacon" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    
    
    func createMediaDirectory(){
        var error: NSError?
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory: AnyObject = paths[0]
        var dataPath = documentsDirectory.stringByAppendingPathComponent(kMediaDirectory)
        if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
            NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
    }
    
    func fileExists(fileName:String)->Bool{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0] as String
        let fullFilePath = documentDirectory.stringByAppendingPathComponent(fileName)
        return  NSFileManager.defaultManager().fileExistsAtPath(fullFilePath)
    }
    
    
    func makeFullPathForFileName(fileName:String)->String{
        var error: NSError?
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory: AnyObject = paths[0]
        return documentsDirectory.stringByAppendingPathComponent(kMediaDirectory) + "/" + fileName
        
    }
    
    func saveFileWithData(imageData:NSData,fileName:String){
        //make sure there is data
        if (imageData.length > 0){
            //always overwrite
            //if !fileExists(fileName){
                var image:UIImage = UIImage(data: imageData)!
                var ext = fileName.pathExtension
                if (ext == "jpg" || ext == "jpeg"){
                      UIImageJPEGRepresentation(image,1.0).writeToFile(makeFullPathForFileName(fileName), atomically: true)
                }
                else if (ext == "png"){
                    var img:UIImage = UIImage(data:imageData)!
                    var data:NSData = UIImagePNGRepresentation(img)
                    data.writeToFile(makeFullPathForFileName(fileName), atomically: true)
                    
                }
            //}
        }
    }
}

