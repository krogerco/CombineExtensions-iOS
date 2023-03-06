//
//  AssignTo.swift
//  CombineExtensions
//
//  Created by Isaac Ruiz on 3/1/23.
//

import Foundation
import Combine

extension Publisher where Failure == Never {

    /// Assigns each element from a publisher to a property on an object.
    ///
    /// Prefer assign to publisher.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign.
    ///   - object: The object that contains the property. The subscriber assigns the object’s property every time it receives a new value.
    ///   - ownership: The retainment / ownership strategy for the object.
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    func assign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {

        switch ownership {
        case .weak:
            return sink { [weak object] value in
                object?[keyPath: keyPath] = value
            }

        case .strong:
            return assign(to: keyPath, on: object)
        }
    }
}
