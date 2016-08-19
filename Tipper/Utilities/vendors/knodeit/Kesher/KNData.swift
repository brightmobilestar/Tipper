//
//  KNData.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

public protocol DataConvertible {
    typealias Result
    class func convertFromData(data:NSData) -> Result?
}

public protocol DataRepresentable {
    func asData() -> NSData!
}

extension UIImage : DataConvertible, DataRepresentable {
    public typealias Result = UIImage
    public class func convertFromData(data:NSData) -> Result? {
        let image = UIImage(data: data)
        return image
    }
    
    public func asData() -> NSData! {
        return nil
    }
    
}


