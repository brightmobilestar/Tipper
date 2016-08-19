//
//  KNBKTry.swift
//  Wrappers
//
//  Created by Jianying Shi on  2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public struct KNBKTryError {
    public static let domain = "Wrappers"
    public static let filterFailed = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Filter failed"])
}

public enum KNBKTry<T> {

    case Success(KNBKBox<T>)
    case Failure(NSError)
    
    public init(_ value:T) {
        self = .Success(KNBKBox(value))
    }

    public init(_ value:KNBKBox<T>) {
        self = .Success(value)
    }

    public init(_ error:NSError) {
        self = .Failure(error)
    }
    
    
    public func isSuccess() -> Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    public func isFailure() -> Bool {
        switch self {
        case .Success:
            return false
        case .Failure:
            return true
        }
    }
    
    public func map<M>(mapping:T -> M) -> KNBKTry<M> {
        switch self {
        case .Success(let box):
            return KNBKTry<M>(box.map(mapping))
        case .Failure(let error):
            return KNBKTry<M>(error)
        }
    }
    
    public func flatmap<M>(mapping:T -> KNBKTry<M>) -> KNBKTry<M> {
        switch self {
        case .Success(let box):
            return mapping(box.value)
        case .Failure(let error):
            return KNBKTry<M>(error)
        }
    }
    
    public func recover(recovery:NSError -> T) -> KNBKTry<T> {
        switch self {
        case .Success(let box):
            return KNBKTry(box)
        case .Failure(let error):
            return KNBKTry<T>(recovery(error))
        }
    }
    
    public func recoverWith(recovery:NSError -> KNBKTry<T>) -> KNBKTry<T> {
        switch self {
        case .Success(let box):
            return KNBKTry(box)
        case .Failure(let error):
            return recovery(error)
        }
    }
    
    public func filter(predicate:T -> Bool) -> KNBKTry<T> {
        switch self {
        case .Success(let box):
            if !predicate(box.value) {
                return KNBKTry<T>(KNBKTryError.filterFailed)
            } else {
                return KNBKTry(box)
            }
        case .Failure(let error):
            return self
        }
    }
    
    public func foreach(apply:T -> Void) {
        switch self {
        case .Success(let box):
            apply(box.value)
        case .Failure:
            return
        }
    }
    
    public func toOptional() -> Optional<T> {
        switch self {
        case .Success(let box):
            return Optional<T>(box.value)
        case .Failure(let error):
            return Optional<T>()
        }
    }
    
    public func getOrElse(failed:T) -> T {
        switch self {
        case .Success(let box):
            return box.value
        case .Failure(let error):
            return failed
        }
    }
    
    public func orElse(failed:KNBKTry<T>) -> KNBKTry<T> {
        switch self {
        case .Success(let box):
            return KNBKTry(box)
        case .Failure(let error):
            return failed
        }
    }
    
}

public func flatten<T>(try:KNBKTry<KNBKTry<T>>) -> KNBKTry<T> {
    switch try {
    case .Success(let box):
        return box.value
    case .Failure(let error):
        return KNBKTry<T>(error)
    }
}

public func forcomp<T,U>(f:KNBKTry<T>, g:KNBKTry<U>, #apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(f:KNBKTry<T>, g:KNBKTry<U>, h:KNBKTry<V>, #apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.foreach {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(f:KNBKTry<T>, g:KNBKTry<U>, #yield:(T,U) -> V) -> KNBKTry<V> {
    return f.flatmap {fvalue in
        g.map {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(f:KNBKTry<T>, g:KNBKTry<U>, h:KNBKTry<V>, #yield:(T,U,V) -> W) -> KNBKTry<W> {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.map {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U>(f:KNBKTry<T>, g:KNBKTry<U>, #filter:(T,U) -> Bool, #apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.filter{gvalue in
            filter(fvalue, gvalue)
            }.foreach {gvalue in
                apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(f:KNBKTry<T>, g:KNBKTry<U>, h:KNBKTry<V>, #filter:(T,U,V) -> Bool, #apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.filter{hvalue in
                filter(fvalue, gvalue, hvalue)
                }.foreach {hvalue in
                    apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(f:KNBKTry<T>, g:KNBKTry<U>, #filter:(T,U) -> Bool, #yield:(T,U) -> V) -> KNBKTry<V> {
    return f.flatmap {fvalue in
        g.filter {gvalue in
            filter(fvalue, gvalue)
            }.map {gvalue in
                yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(f:KNBKTry<T>, g:KNBKTry<U>, h:KNBKTry<V>, #filter:(T,U,V) -> Bool, #yield:(T,U,V) -> W) -> KNBKTry<W> {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.filter {hvalue in
                filter(fvalue, gvalue, hvalue)
                }.map {hvalue in
                    yield(fvalue, gvalue, hvalue)
            }
        }
    }

}

