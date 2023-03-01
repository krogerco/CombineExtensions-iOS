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
    ///     from self with the latest value from the second publisher, if any.
    ///
    /// - Parameter other: Second observable source.
    /// - Returns: A publisher containing the result of combining each value of the self
    ///            with the latest value from the second publisher, if any, using the
    ///            specified result selector function.
    public func withLatestFrom<Secondary: Publisher>( _ other: Secondary) -> AnyPublisher<(Output, Secondary.Output), Failure>
        where Secondary.Failure == Failure
    {
        return Publishers.WithLatestFrom(upstream: self, secondary: other).eraseToAnyPublisher()
    }

}

extension Publishers {

    struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher
        where Upstream.Failure == Other.Failure
    {

        /// Tuple represening the upstream and other output.
        public typealias Output = (Upstream.Output, Other.Output)
        public typealias Failure = Upstream.Failure

        let upstream: Upstream
        let second: Other

        public init(upstream: Upstream, secondary: Other) {
            self.upstream = upstream
            self.second = secondary
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

    class Subscription<S: Subscriber>: Combine.Subscription, CustomStringConvertible where S.Input == Output, S.Failure == Failure {

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

            return upstreamSubscription = upstream
                .sink(
                  receiveCompletion: { [subscriber] in subscriber.receive(completion: $0) },
                  receiveValue: { [weak self] value in
                    guard let self else { return }
                    guard let latestValue = self.latestValue else { return }

                    _ = self.subscriber.receive((value, latestValue))
                })


        }

        func trackLatestValue() {

            secondSubscription = second
                .sink(receiveCompletion: {_ in },
                      receiveValue: { [weak self] value in
                     self?.latestValue = value
                })
        }

        var description: String {
            "Publishers.WithLatestFrom<\(String(describing: S.Input.self)), \(String(describing: S.Failure.self))>.Subscription"
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
