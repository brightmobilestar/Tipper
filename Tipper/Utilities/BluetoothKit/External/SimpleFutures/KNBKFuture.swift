//
//  KNBKFuture.swift
//  SimpleFutures
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public struct SimpleFuturesError {
    static let domain = "SimpleFutures"
    static let futureCompleted      = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"KNBKFuture has been completed"])
    static let futureNotCompleted   = NSError(domain:domain, code:2, userInfo:[NSLocalizedDescriptionKey:"KNBKFuture has not been completed"])
}

public struct SimpleFuturesException {
    static let futureCompleted = NSException(name:"KNBKFuture complete error", reason: "KNBKFuture previously completed.", userInfo:nil)
}




// KNBKFuture
public class KNBKFuture<T> {
    
    private var result:KNBKTry<T>?
    
    internal let defaultExecutionContext: ExecutionContext  = KNBKQueueContext.main
    typealias OnComplete                                    = KNBKTry<T> -> Void
    private var saveCompletes                               = [OnComplete]()
    
    public init() {
    }
    
    // should be Futureable protocol
    public func onComplete(executionContext:ExecutionContext, complete:KNBKTry<T> -> Void) -> Void {
        KNBKQueue.simpleFutures.sync {
            let savedCompletion : OnComplete = {result in
                executionContext.execute {
                    complete(result)
                }
            }
            if let result = self.result {
                savedCompletion(result)
            } else {
                self.saveCompletes.append(savedCompletion)
            }
        }
    }
    
    // should be future mixin
    internal func complete(result:KNBKTry<T>) {
        KNBKQueue.simpleFutures.sync {
            if self.result != nil {
                //SimpleFuturesException.futureCompleted.raise()
            }
            self.result = result
            for complete in self.saveCompletes {
                complete(result)
            }
            self.saveCompletes.removeAll()
        }
    }
    
    public func onComplete(complete:KNBKTry<T> -> Void) {
        self.onComplete(self.defaultExecutionContext, complete)
    }

    public func onSuccess(success:T -> Void) {
        self.onSuccess(self.defaultExecutionContext, success)
    }
    
    public func onSuccess(executionContext:ExecutionContext, success:T -> Void){
        self.onComplete(executionContext) {result in
            switch result {
            case .Success(let valueBox):
                success(valueBox.value)
            default:
                break
            }
        }
    }

    public func onFailure(failure:NSError -> Void) -> Void {
        return self.onFailure(self.defaultExecutionContext, failure)
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

    public func map<M>(mapping:T -> KNBKTry<M>) -> KNBKFuture<M> {
        return map(self.defaultExecutionContext, mapping:mapping)
    }
    
    public func map<M>(executionContext:ExecutionContext, mapping:T -> KNBKTry<M>) -> KNBKFuture<M> {
        let future = KNBKFuture<M>()
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    public func flatmap<M>(mapping:T -> KNBKFuture<M>) -> KNBKFuture<M> {
        return self.flatmap(self.defaultExecutionContext, mapping:mapping)
    }

    public func flatmap<M>(executionContext:ExecutionContext, mapping:T -> KNBKFuture<M>) -> KNBKFuture<M> {
        let future = KNBKFuture<M>()
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
    
    public func andThen(complete:KNBKTry<T> -> Void) -> KNBKFuture<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    public func andThen(executionContext:ExecutionContext, complete:KNBKTry<T> -> Void) -> KNBKFuture<T> {
        let future = KNBKFuture<T>()
        future.onComplete(executionContext, complete)
        self.onComplete(executionContext) {result in
            future.complete(result)
        }
        return future
    }
    
    public func recover(recovery: NSError -> KNBKTry<T>) -> KNBKFuture<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recover(executionContext:ExecutionContext, recovery:NSError -> KNBKTry<T>) -> KNBKFuture<T> {
        let future = KNBKFuture<T>()
        self.onComplete(executionContext) {result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    public func recoverWith(recovery:NSError -> KNBKFuture<T>) -> KNBKFuture<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    public func recoverWith(executionContext:ExecutionContext, recovery:NSError -> KNBKFuture<T>) -> KNBKFuture<T> {
        let future = KNBKFuture<T>()
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
    
    public func withFilter(filter:T -> Bool) -> KNBKFuture<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    public func withFilter(executionContext:ExecutionContext, filter:T -> Bool) -> KNBKFuture<T> {
        let future = KNBKFuture<T>()
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
    
    internal func completeWith(future:KNBKFuture<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    internal func completeWith(executionContext:ExecutionContext, future:KNBKFuture<T>) {
        let isCompleted = KNBKQueue.simpleFutures.sync {Void -> Bool in
            return self.result != nil
        }
        if isCompleted == false {
            future.onComplete(executionContext) {result in
                self.complete(result)
            }
        }
    }
    
    internal func success(value:T) {
        self.complete(KNBKTry(value))
    }
    
    internal func failure(error:NSError) {
        self.complete(KNBKTry<T>(error))
    }
    
}

// create futures
public func future<T>(computeResult:Void -> KNBKTry<T>) -> KNBKFuture<T> {
    return future(KNBKQueueContext.global, computeResult)
}

public func future<T>(executionContext:ExecutionContext, calculateResult:Void -> KNBKTry<T>) -> KNBKFuture<T> {
    let promise = KNBKPromise<T>()
    executionContext.execute {
        promise.complete(calculateResult())
    }
    return promise.future
}

public func forcomp<T,U>(f:KNBKFuture<T>, g:KNBKFuture<U>, #apply:(T,U) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f, g, apply:apply)
}

public func forcomp<T,U>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, #apply:(T,U) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            apply(fvalue, gvalue)
        }
    }
}


// for comprehensions
public func forcomp<T,U>(f:KNBKFuture<T>, g:KNBKFuture<U>, #filter:(T,U) -> Bool, #apply:(T,U) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f, g, filter:filter, apply:apply)
}

public func forcomp<T,U>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, #filter:(T,U) -> Bool, #apply:(T,U) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.withFilter(executionContext) {gvalue in
            filter(fvalue, gvalue)
            }.foreach(executionContext) {gvalue in
                apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #apply:(T,U,V) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f, g, h, apply:apply)
}

public func forcomp<T,U,V>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #apply:(T,U,V) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            h.foreach(executionContext) {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #filter:(T,U,V) -> Bool, #apply:(T,U,V) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f, g, h, filter:filter, apply:apply)
}

public func forcomp<T,U,V>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #filter:(T,U,V) -> Bool, #apply:(T,U,V) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            h.withFilter(executionContext) {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.foreach(executionContext) {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(f:KNBKFuture<T>, g:KNBKFuture<U>, #yield:(T,U) -> KNBKTry<V>) -> KNBKFuture<V> {
    return forcomp(f.defaultExecutionContext, f, g, yield:yield)
}

public func forcomp<T,U,V>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, #yield:(T,U) -> KNBKTry<V>) -> KNBKFuture<V> {
    return f.flatmap(executionContext) {fvalue in
        g.map(executionContext) {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(f:KNBKFuture<T>, g:KNBKFuture<U>, #filter:(T,U) -> Bool, #yield:(T,U) -> KNBKTry<V>) -> KNBKFuture<V> {
    return forcomp(f.defaultExecutionContext, f, g, filter:filter, yield:yield)
}

public func forcomp<T,U,V>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, #filter:(T,U) -> Bool, #yield:(T,U) -> KNBKTry<V>) -> KNBKFuture<V> {
    return f.flatmap(executionContext) {fvalue in
        g.withFilter(executionContext) {gvalue in
            filter(fvalue, gvalue)
        }.map(executionContext) {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #yield:(T,U,V) -> KNBKTry<W>) -> KNBKFuture<W> {
    return forcomp(f.defaultExecutionContext, f, g, h, yield:yield)
}

public func forcomp<T,U,V,W>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #yield:(T,U,V) -> KNBKTry<W>) -> KNBKFuture<W> {
    return f.flatmap(executionContext) {fvalue in
        g.flatmap(executionContext) {gvalue in
            h.map(executionContext) {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U, V, W>(f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #filter:(T,U,V) -> Bool, #yield:(T,U,V) -> KNBKTry<W>) -> KNBKFuture<W> {
    return forcomp(f.defaultExecutionContext, f, g, h, filter:filter, yield:yield)
}

public func forcomp<T,U, V, W>(executionContext:ExecutionContext, f:KNBKFuture<T>, g:KNBKFuture<U>, h:KNBKFuture<V>, #filter:(T,U,V) -> Bool, #yield:(T,U,V) -> KNBKTry<W>) -> KNBKFuture<W> {
    return f.flatmap(executionContext) {fvalue in
        g.flatmap(executionContext) {gvalue in
            h.withFilter(executionContext) {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.map(executionContext) {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

