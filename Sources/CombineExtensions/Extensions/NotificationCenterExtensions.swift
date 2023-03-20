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

extension NotificationCenter {

    /// Merges notifications from multiple `Notification.Name`s into a single event stream.
    ///
    /// - Parameters:
    ///   - names: The names of the notifications to publish. Duplicate names will be ignored.
    /// - Returns: A publisher that emits events when broadcasting notifications with the given names.
    public func publisher(for names: [Notification.Name]) -> AnyPublisher<Notification, Never> {

        let publishers = Set(names) // dedupe
                .map { notificationName in
                    self.publisher(for: notificationName, object: nil)
                }

        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }

}
