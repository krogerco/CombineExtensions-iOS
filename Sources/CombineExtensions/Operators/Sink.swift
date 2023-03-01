//
//  File.swift
//  
//
//  Created by Isaac Ruiz on 3/1/23.
//

import Foundation
import Combine

enum SinkError: Error {
    case nilObject
}

public extension Publisher where Failure == Never {

    func sink<T: AnyObject>(
        to function: @escaping (T) -> () -> (),
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {

        switch ownership {
        case .strong:
            return self
                .sink { value in
                    function(object)()
                }

        case .weak:
            return self
                .tryMap { [weak object] value in
                    guard let strongObject = object else {
                        throw SinkError.nilObject
                    }
                    return strongObject
                }
                .catchSilently()
                .sink { object in
                    function(object)()
                }
        }

    }

    func sink<T: AnyObject>(
        to function: @escaping (T) -> (Output) -> (),
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {

        switch ownership {
        case .strong:
            return self
                .sink { value in
                    function(object)(value)
                }

        case .weak:
            return self
                .tryMap { [weak object] value in
                    guard let strongObject = object else {
                        throw SinkError.nilObject
                    }
                    return (strongObject, value)
                }
                .catchSilently()
                .sink { object, value in
                    function(object)(value)
                }
        }
    }
}

extension Publisher {
    func catchSilently() -> AnyPublisher<Output, Never> {
        self
            .catch { error in
                return Empty<Output, Never>()
            }
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }
}
