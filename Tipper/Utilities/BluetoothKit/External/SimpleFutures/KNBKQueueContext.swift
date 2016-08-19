//
//  KNBKQueueContext.swift
//  BluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public protocol ExecutionContext {
    
    func execute(task:Void->Void)
}

public class KNBKQueueContext : ExecutionContext {
    
    public class var main : KNBKQueueContext {
        struct Static {
            static let instance = KNBKQueueContext(queue:KNBKQueue.main)
        }
        return Static.instance
    }
    
    public class var global: KNBKQueueContext {
        struct Static {
            static let instance : KNBKQueueContext = KNBKQueueContext(queue:KNBKQueue.global)
        }
        return Static.instance
    }
    
    let queue:KNBKQueue
    
    public init(queue:KNBKQueue) {
        self.queue = queue
    }
    
    public func execute(task:Void -> Void) {
        queue.async(task)
    }
}


