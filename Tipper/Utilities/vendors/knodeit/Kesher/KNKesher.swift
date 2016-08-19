//
//  KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

public struct KNKesherConfiguration {
    
    public static let Namespace = "io.KNKesher"
    public static let AnimationDuration = 1.0
}

public struct Shared {
    public static var imageCache : KNCache<UIImage> {
        struct Static {
            static let name = "KNKesher-cached-images"
            static let cache = KNCache<UIImage>(name: name)
        }
        return Static.cache
    }
}

func errorWithCode(code : Int, #description : String) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: description]
    return NSError(domain: KNKesherConfiguration.Namespace, code: code, userInfo: userInfo)
}


struct KNLogger {
    static func error(message : String, _ error : NSError? = nil) {
        if let error = error {
            println("%@ with error %@", message, error);
        } else {
            println("%@", message)
        }
    }
    
}