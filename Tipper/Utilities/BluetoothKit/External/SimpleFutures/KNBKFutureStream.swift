//
//  KNBKFutureStream.swift
//  BluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKFutureStream<T> {
    
    private var futures         = [KNBKFuture<T>]()
    private typealias InFuture  = KNBKFuture<T> -> Void
    private var saveCompletes   = [InFuture]()
    private var capacity        : Int?
    
    internal let defaultExecutionContext: ExecutionContext  = KNBKQueueContext.main

    public var count : Int {
        return futures.count
    }
    
    public init() {
    }
    
    public init(capacity:Int) {
        self.capacity = capacity
    }
    
    // Futureable protocol
    public func onComplete(executionContext:ExecutionContext, complete:KNBKTry<T> -> Void) {
        KNBKQueue.simpleFutureStreams.sync {
            let futureComplete : InFuture = {future in
                future.onComplete(executionContext, complete)
            }
            self.saveCompletes.append(futureComplete)
            for future in self.futures {
                futureComplete(future)
            }
        }
    }

    internal func complete(result:KNBKTry<T>) {
        let future = KNBKFuture<T>()
        future.complete(result)
        KNBKQueue.simpleFutureStreams.sync {
            self.addFuture(future)
            for complete in self.saveCompletes {
                complete(future)
            }
        }
    }
    
    // should be future mixin
    public func onComplete(complete:KNBKTry<T> -> Void) {
        self.onComplete(self.defaultExecutionContext, complete)
    }
    
    public func onSuccess(success:T -> Void) {
        self.onSuccess(self.defaultExecutionContext, success:success)
    }

    public func onSuccess(executionContext:ExecutionContext, success:T -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                success(resultBox.value)
            default:
                break
            }
        }
    }

    public func onFailure(failure:NSError -> Void) {
        self.onFailure(self.defaultExecutionContext, failure:failure)
    }

    public func onFailure(executionContext:ExecutionContext, failure:NSError -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .Failure(let error):
                failure(error)
            default:
                break
            }
        }
    }
    
    public func map<M>(mapping:T -> KNBKTry<M>) -> KNBKFutureStream<M> {
        return self.map(self.defaultExecutionContext, mapping)
    }
    
    public func map<M>(executionContext:ExecutionContext, mapping:T -> KNBKTry<M>) -> KNBKFutureStream<M> {
        let future : KNBKFutureStream<M> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    public func flatmap<M>(mapping:T -> KNBKFutureStream<M>) -> KNBKFutureStream<M> {
        return self.flatMap(self.defaultExecutionContext, mapping)
    }
    
    public func flatMap<M>(executionContext:ExecutionContext, mapping:T -> KNBKFutureStream<M>) -> KNBKFutureStream<M> {
        let future : KNBKFutureStream<M> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.completeWith(executionContext, stream:mapping(resultBox.value))
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }

    public func andThen(complete:KNBKTry<T> -> Void) -> KNBKFutureStream<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    public func andThen(executionContext:ExecutionContext, complete:KNBKTry<T> -> Void) -> KNBKFutureStream<T> {
        let future : KNBKFutureStream<T> = self.createWithCapacity()
        future.onComplete(executionContext, complete:complete)
        self.onComplete(executionContext) {result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(recovery:NSError -> KNBKTry<T>) -> KNBKFutureStream<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recover(executionContext:ExecutionContext, recovery:NSError -> KNBKTry<T>) -> KNBKFutureStream<T> {
        let future : KNBKFutureStream<T> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(recovery:NSError -> KNBKFutureStream<T>) -> KNBKFutureStream<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> KNBKFutureStream<T>) -> KNBKFutureStream<T> {
        let future : KNBKFutureStream<T> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.success(resultBox.value)
            case .Failure(let error):
                future.completeWith(executionContext, stream:recovery(error))
            }
        }
        return future
    }

    public func withFilter(filter:T -> Bool) -> KNBKFutureStream<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> KNBKFutureStream<T> {
        let future : KNBKFutureStream<T> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            future.complete(result.filter(filter))
        }
        return future
    }

    public func foreach(apply:T -> Void) {
        self.foreach(self.defaultExecutionContext, apply:apply)
    }
    
    public func foreach(executionContext:ExecutionContext, apply:T -> Void) {
        self.onComplete(executionContext) {result in
            result.foreach(apply)
        }
    }

    internal func completeWith(stream:KNBKFutureStream<T>) {
        self.completeWith(self.defaultExecutionContext, stream:stream)
    }
    
    internal func completeWith(executionContext:ExecutionContext, stream:KNBKFutureStream<T>) {
        stream.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    internal func success(value:T) {
        self.complete(KNBKTry(value))
    }
    
    internal func failure(error:NSError) {
        self.complete(KNBKTry<T>(error))
    }
    
    // future stream extensions
    public func flatmap<M>(mapping:T -> KNBKFuture<M>) -> KNBKFutureStream<M> {
        return self.flatMap(self.defaultExecutionContext, mapping)
    }
    
    public func flatMap<M>(executionContext:ExecutionContext, mapping:T -> KNBKFuture<M>) -> KNBKFutureStream<M> {
        let future : KNBKFutureStream<M> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.completeWith(executionContext, future:mapping(resultBox.value))
            case .Failure(let error):
                future.failure(error)
            }
        }
        return future
    }

    public func recoverWith(recovery:NSError -> KNBKFuture<T>) -> KNBKFutureStream<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> KNBKFuture<T>) -> KNBKFutureStream<T> {
        let future : KNBKFutureStream<T> = self.createWithCapacity()
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let resultBox):
                future.success(resultBox.value)
            case .Failure(let error):
                future.completeWith(executionContext, future:recovery(error))
            }
        }
        return future
    }
    
    internal func completeWith(future:KNBKFuture<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    internal func completeWith(executionContext:ExecutionContext, future:KNBKFuture<T>) {
        future.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    private func addFuture(future:KNBKFuture<T>) {
        if let capacity = self.capacity {
            if self.futures.count >= capacity {
                self.futures.removeAtIndex(0)
            }
        }
        self.futures.append(future)
    }
    
    private func createWithCapacity<M>() -> KNBKFutureStream<M> {
        if let capacity = capacity {
            return KNBKFutureStream<M>(capacity:capacity)
        } else {
            return KNBKFutureStream<M>()
        }
    }
}