//
//  SinkTo.swift
//  CombineExtensions
//
//  Created by Isaac Ruiz on 3/1/23.
//

import Foundation
import Combine

extension Publisher where Failure == Never     {

    /// Attaches a subscriber to a publisher that never fails.
    /// - Parameters:
    ///   - function: A function reference defined on a type.
    ///   - object: The object to pass to the function reference, thus calling the function.
    ///   - ownership: The retainment / ownership strategy for the object.
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink<T: AnyObject>(
        to function: @escaping (T) -> () -> (),
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {
        switch ownership {
        case .strong:
            return sink { value in
                function(object)()
            }

        case .weak:
            return sink { [weak object] _ in
                guard let object else { return }
                function(object)()
            }
        }
    }

    /// Attaches a subscriber to a publisher that never fails.
    /// - Parameters:
    ///   - function: A function reference defined on a type.
    ///   - object: The object to pass to the function reference, thus calling the function.
    ///   - ownership: The retainment / ownership strategy for the object.
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink<T: AnyObject>(
        to function: @escaping (T) -> (Output) -> (),
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {

        switch ownership {
        case .strong:
            return sink { value in
                function(object)(value)
            }

        case .weak:
            return sink { [weak object] value in
                guard let object else { return }
                function(object)(value)
            }
        }
    }
}
