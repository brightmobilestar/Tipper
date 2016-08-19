//
//  KNFetch.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

enum KNFetchState<T> {
    case Pending
    
    case Success(Wrapper<T>)
    case Failure(NSError?)
}

public class KNFetch<T> {
    
    public typealias Succeeder = (T) -> ()
    
    public typealias Failer = (NSError?) -> ()
    
    private var onSuccess : Succeeder?
    
    private var onFailure : Failer?
    
    private var state : KNFetchState<T> = KNFetchState.Pending
    
    public init() {}
    
    public func onSuccess(onSuccess : Succeeder) -> Self {
        self.onSuccess = onSuccess
        switch self.state {
        case KNFetchState.Success(let wrapper):
            onSuccess(wrapper.value)
        default:
            break
        }
        return self
    }
    
    public func onFailure(onFailure : Failer) -> Self {
        self.onFailure = onFailure
        switch self.state {
        case KNFetchState.Failure(let error):
            onFailure(error)
        default:
            break
        }
        return self
    }
    
    func succeed(value : T) {
        self.state = KNFetchState.Success(Wrapper(value))
        self.onSuccess?(value)
    }
    
    func fail(_ error : NSError? = nil) {
        self.state = KNFetchState.Failure(error)
        self.onFailure?(error)
    }
    
    var hasFailed : Bool {
        switch self.state {
        case KNFetchState.Failure(_):
            return true
        default:
            return false
        }
    }
    
    var hasSucceeded : Bool {
        switch self.state {
        case KNFetchState.Success(_):
            return true
        default:
            return false
        }
    }
    
}

public class Wrapper<T> {
    public let value: T
    public init(_ value: T) { self.value = value }
}

