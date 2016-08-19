//
//  KNFetcher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

public class KNFetcher<T : DataConvertible> {
    
    let key : String
    
    init(key : String) {
        self.key = key
    }
    
    func fetch(failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {}
    
    func cancelFetch() {}
}

class KNSimpleFetcher<T : DataConvertible> : KNFetcher<T> {
    
    let getValue : () -> T.Result
    
    init(key : String, value getValue : @autoclosure () -> T.Result) {
        self.getValue = getValue
        super.init(key: key)
    }
    
    override func fetch(failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {
        let value = getValue()
        succeed(value)
    }
    
    override func cancelFetch() {}
    
}
