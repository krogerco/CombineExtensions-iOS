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
import XCTest
@testable import CombineExtensions

final class WithLatestFromTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func testOperatorExtension() {

        // Given
        let primary = PassthroughSubject<String, Never>()
        let secondary = PassthroughSubject<Int, Never>()

        let publisher = primary.withLatestFrom(secondary)

        // When
        var capturedValues = [String]()
        publisher
            .map { $0 + $1.description }
            .sink { value in
                capturedValues.append(value)
            }
            .store(in: &subscriptions)

        secondary.send(1)
        primary.send("A")
        secondary.send(100) // Won't trigger publisher, waiting on primary to send again.
        secondary.send(200)
        secondary.send(2)
        primary.send("B")

        // Then
        XCTAssertEqual(capturedValues, ["A1", "B2"])
    }

    func testPubisherCompletesWhenUpstreamCompletes() {

        let primary = PassthroughSubject<String, Never>()
        let secondary = PassthroughSubject<String, Never>()

        var completed = false
        var results = [String]()
        primary
            .withLatestFrom(secondary)
            .map { $0 + $1 }
            .sink(
                receiveCompletion: { _ in
                    completed = true
                },
                receiveValue: { results.append($0) }
            )
            .store(in: &subscriptions)

        secondary.send("1")
        primary.send("A")
        secondary.send("2")
        secondary.send("3")
        primary.send("B")

        XCTAssertEqual(results, ["A1", "B3"])

        XCTAssertFalse(completed)
        secondary.send(completion: .finished)

        XCTAssertFalse(completed)
        primary.send(completion: .finished)

        XCTAssertTrue(completed)
    }

    func testPublisherInializer() {

        let primary = PassthroughSubject<String, Never>()
        let secondary = PassthroughSubject<String, Never>()

        let publisher = Publishers.WithLatestFrom(upstream: primary, secondary: secondary)

        XCTAssertEqual(ObjectIdentifier(publisher.upstream), ObjectIdentifier(primary))
        XCTAssertEqual(ObjectIdentifier(publisher.second), ObjectIdentifier(secondary))
    }

    func testPublisherReceivesSubscriber() {

        // Given
        let publisher = Publishers.WithLatestFrom(upstream: Just(""), secondary: Just(""))

        var subscriptionDescription: String?

        let subscriber = AnySubscriber<(String, String), Never>(
            receiveSubscription: { subscription in
                subscriptionDescription = String(describing: subscription)
            },
            receiveValue: nil,
            receiveCompletion: nil
        )

        // When
        publisher.receive(subscriber: subscriber)

        // Then
        XCTAssertEqual(subscriptionDescription, "Publishers.WithLatestFrom<(String, String), Never>.Subscription")
    }

    // swiftlint:disable force_unwrapping
    func testSubscriberRetainsPublishers() {

        var primary: PassthroughSubject<Int, Never>? = .init()
        var secondary: PassthroughSubject<Int, Never>? = .init()

        weak var weakPrimary = primary
        weak var weakSecondary = secondary

        let subscription = weakPrimary!
            .withLatestFrom(weakSecondary!)
            .sink { _ in }

        // When
        primary = nil
        secondary = nil

        XCTAssertNotNil(weakPrimary)
        XCTAssertNotNil(weakSecondary)

        subscription.cancel()

        // Then
        XCTAssertNil(weakPrimary)
        XCTAssertNil(weakSecondary)
    }
    // swiftlint:enable force_unwrapping
}
