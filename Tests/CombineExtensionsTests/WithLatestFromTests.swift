//
//  File.swift
//  
//
//  Created by Isaac Ruiz on 3/10/23.
//

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
}

