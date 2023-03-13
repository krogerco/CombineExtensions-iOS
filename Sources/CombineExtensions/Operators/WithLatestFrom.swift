//
//  File.swift
//  
//
//  Created by Isaac Ruiz on 3/10/23.
//

import Foundation
import Combine

extension Publisher {

    ///  Merges two publishers into a single publisher by combining each value
    ///  from self with the latest value from the second publisher, if any.
    ///
    /// - Parameter other: Second observable source.
    /// - Note: https://jasdev.me/notes/with-latest-from
    ///         https://gist.github.com/freak4pc/8d46ea6a6f5e5902c3fb5eba440a55c3
    public func withLatestFrom<Other: Publisher>( _ other: Other)
    -> AnyPublisher<(Output, Other.Output), Failure>
    where Other.Failure == Failure
    {
        let upstream = share()

        return other
            .map { second in upstream.map { ($0, second) } }
            .switchToLatest()
            .zip(upstream)
            .map(\.0)
            .eraseToAnyPublisher()
    }
}

extension Publishers {
    public struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher
        where Upstream.Failure == Other.Failure
    {

        public typealias Output = (Upstream.Output, Other.Output)
        public typealias Failure = Upstream.Failure

        let upstream: Upstream
        let second: Other

        public init(upstream: Upstream, second: Other) {

            self.upstream = upstream
            self.second = second
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let sub = Subscription(
                upstream: upstream,
                second: second,
                subscriber: subscriber
            )
            subscriber.receive(subscription: sub)
        }

    }
}

extension Publishers.WithLatestFrom {

    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {

        let subscriber: S
        var latestValue: Other.Output?

        let upstream: Upstream
        let second: Other

        var upstreamSubscription: Cancellable?
        var secondSubscription: Cancellable?

        init(upstream: Upstream,
             second: Other,
             subscriber: S) {
            self.upstream = upstream
            self.second = second
            self.subscriber = subscriber

            trackLatestValue()
        }

        func request(_ demand: Subscribers.Demand) {
        
            upstreamSubscription = upstream
                .print()
                .sink(
                  receiveCompletion: { [subscriber] in subscriber.receive(completion: $0) },
                  receiveValue: { [weak self] value in
                    guard let self = self else { return }
                      Swift.print("latest", self.latestValue)
                    guard let latestValue = self.latestValue else { return }

                    _ = self.subscriber.receive((value, latestValue))
                })
        }

        func trackLatestValue() {

            let subscriber = AnySubscriber<Other.Output, Other.Failure>(
                receiveSubscription: { [weak self] subscription in
                    self?.secondSubscription = subscription
                    subscription.request(.unlimited)
                },
                receiveValue: { [weak self] value in
                    self?.latestValue = value
                    return .unlimited
                },
                receiveCompletion: nil)

            self.second.subscribe(subscriber)
        }

        func cancel() {
            self.upstreamSubscription?.cancel()
            self.secondSubscription?.cancel()
        }

        deinit {
            cancel()
        }
    }
}
