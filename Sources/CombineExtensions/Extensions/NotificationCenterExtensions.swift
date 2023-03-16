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
