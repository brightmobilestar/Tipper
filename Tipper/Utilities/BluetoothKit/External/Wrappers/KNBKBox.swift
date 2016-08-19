//
//  Utilities.swift
//  Wrappers
//
//  Created by Jianying Shi on  2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public final class KNBKBox<T> {
    
    public let value: T
    
    public init(_ value:T) {
        self.value = value
    }
    
    public func map<M>(mapping:T -> M) -> KNBKBox<M> {
        return KNBKBox<M>(mapping(self.value))
    }
    
    public func flatmap<M>(mapping:T -> KNBKBox<M>) -> KNBKBox<M> {
        return mapping(self.value)
    }
}

