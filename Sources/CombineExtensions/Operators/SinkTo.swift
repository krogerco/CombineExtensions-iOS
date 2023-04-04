/*
MIT License

Copyright (c) 2023 The Kroger Co. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation
import Combine

extension Publisher where Failure == Never {

    /// Attaches a subscriber to a publisher that never fails.
    /// - Parameters:
    ///   - function: A function reference defined on a type.
    ///   - object: The object to pass to the function reference, thus calling the function.
    ///   - ownership: The retainment / ownership strategy for the object.
    ///
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value.
    ///            Deallocation of the result will tear down the subscription stream.
    public func sink<T: AnyObject>(
        to function: @escaping (T) -> () -> Void,
        on object: T,
        ownership: ObjectOwnership
    ) -> AnyCancellable {
        switch ownership {
        case .strong:
            return sink { _ in
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
    ///   
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value.
    ///            Deallocation of the result will tear down the subscription stream.
    public func sink<T: AnyObject>(
        to function: @escaping (T) -> (Output) -> Void,
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
