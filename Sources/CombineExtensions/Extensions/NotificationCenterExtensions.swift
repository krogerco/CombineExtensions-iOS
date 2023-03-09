//
//  File.swift
//  
//
//  Created by Isaac Ruiz on 3/8/23.
//

import Foundation
import Combine

extension NotificationCenter {

    /// Merges notifications from multiple `Notification.Name`s into a single event stream.
    ///
    /// - Parameters:
    ///   - names: The names of the notifications to publish.
    ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given names.
    /// - Returns: A publisher that emits events when broadcasting notifications with the given names.
    public func publisher(for names: [Notification.Name], object: AnyObject? = nil) -> AnyPublisher<Notification, Never> {

        let publishers = names.map { notificationName in
            self.publisher(for: notificationName, object: object)
        }

        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }
}
