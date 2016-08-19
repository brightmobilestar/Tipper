//
//  KNBKStreamPromise.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit

public class KNBKStreamPromise<T> {
    
    public let future : KNBKFutureStream<T>
    
    public init() {
        self.future = KNBKFutureStream<T>()
    }
    
    public init(capacity:Int) {
        self.future = KNBKFutureStream<T>(capacity:capacity)
    }
    
    public func complete(result:KNBKTry<T>) {
        self.future.complete(result)
    }
    
    public func completeWith(future:KNBKFuture<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    public func completeWith(executionContext:ExecutionContext, future:KNBKFuture<T>) {
        future.completeWith(future)
    }
    
    public func success(value:T) {
        self.future.success(value)
    }
    
    public func failure(error:NSError) {
        self.future.failure(error)
    }
    
    public func completeWith(stream:KNBKFutureStream<T>) {
        self.completeWith(self.future.defaultExecutionContext, stream:stream)
    }
    
    public func completeWith(executionContext:ExecutionContext, stream:KNBKFutureStream<T>) {
        future.completeWith(stream)
    }
    
}


