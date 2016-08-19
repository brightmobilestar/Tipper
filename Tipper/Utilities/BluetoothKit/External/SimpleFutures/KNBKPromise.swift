//
//  KNBKPromise.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit

// KNBKPromise
public class KNBKPromise<T> {
    
    public let future = KNBKFuture<T>()
    
    public init() {
    }
    
    public func completeWith(future:KNBKFuture<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    public func completeWith(executionContext:ExecutionContext, future:KNBKFuture<T>) {
        self.future.completeWith(executionContext, future:future)
    }
    
    public func complete(result:KNBKTry<T>) {
        self.future.complete(result)
    }
    
    public func success(value:T) {
        self.future.success(value)
    }
    
    public func failure(error:NSError)  {
        self.future.failure(error)
    }
    
}