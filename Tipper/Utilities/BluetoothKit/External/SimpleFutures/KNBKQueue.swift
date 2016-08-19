//
//  KNBKQueue.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import UIKit


public struct KNBKQueue {
    
    public static let main              = KNBKQueue(dispatch_get_main_queue());
    public static let global            = KNBKQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    
    internal static let simpleFutures       = KNBKQueue("com.knodeit.simpleFutures")
    internal static let simpleFutureStreams = KNBKQueue("com.knodeit.simpleFutureStreams")
    
    var queue: dispatch_queue_t
    
    
    public init(_ queueName:String) {
        self.queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL)
        KNBKLogger.debug(queueName);
    }
    
    public init(_ queue:dispatch_queue_t) {
        self.queue = queue
    }
    
    public func sync(block:Void -> Void) {
        dispatch_sync(self.queue, block)
    }
    
    public func sync<T>(block:Void -> T) -> T {
        var result:T!
        dispatch_sync(self.queue, {
            result = block();
        });
        return result;
    }
    
    public func async(block:dispatch_block_t) {
        dispatch_async(self.queue, block);
    }
    
}