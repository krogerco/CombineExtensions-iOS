//
//  File.swift
//  
//
//  Created by Isaac Ruiz on 3/10/23.
//

import Foundation
import Combine
import XCTest

final class WithLatestFromTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func test_compound_one() {

        // Given
        let primary = PassthroughSubject<String, Never>()
        let secondary = CurrentValueSubject<Int, Never>(0)

        let queueA = DispatchQueue(label: "A")
        let queueB = DispatchQueue(label: "B")

        let publisher = primary.receive(on: queueA).withLatestFrom(secondary).receive(on: queueB)

        // When
        var capturedValues = [String]()
        publisher
            .map { "\($0)-\($1)" }
            .sink { value in
                capturedValues.append(value)
            }
            .store(in: &subscriptions)

        secondary.send(1)
        primary.send("A")
        secondary.send(100) // Won't trigger publisher, waiting on primary to send again.
        secondary.send(2)
        primary.send("B")



        // Then
        XCTAssertEqual(capturedValues, ["A-1", "B-2"])
    }

    func test_withLatestFrom_doesnt_publish_when_secondary_updates() {

        // Given
        let primary = PassthroughSubject<String, Never>()
        let secondary = CurrentValueSubject<Int, Never>(0)

        let publisher = Publishers.WithLatestFrom(upstream: primary, second: secondary).eraseToAnyPublisher()

        // When
        var capturedValues = [String]()
        publisher
            .map { "\($0)-\($1)" }
            .sink { value in
                capturedValues.append(value)
            }
            .store(in: &subscriptions)

        secondary.send(1)
        primary.send("A")
        secondary.send(100) // Won't trigger publisher, waiting on primary to send again.
        secondary.send(2)
        primary.send("B")

        // Then
        XCTAssertEqual(capturedValues, ["A-1", "B-2"])
    }


    func test_withLatestFrom_doesnt_publish_when_secondary_updates_queue() {

        let object = MockObject<(String)>(fulfillCount: 2)

        // Given
        let primary = PassthroughSubject<String, Never>()
        let secondary = CurrentValueSubject<Int, Never>(0)

        let queueA = DispatchQueue(label: "A")
        let queueB = DispatchQueue(label: "B")

        /*

         Different Queues, doesn't work
            upstream: primary.receive(on: queueB),
            second: secondary.receive(on: queueA)

         Different Queues, doesn't work
            upstream: primary.subscribe(on: queueB),
            second: secondary.subscribe(on: queueA)
         */
        
        let publisher = Publishers.WithLatestFrom(
            upstream: primary.subscribe(on: queueB),
            second: secondary
        ).eraseToAnyPublisher()

        // When
        publisher
            .receive(on: queueA)
            .map { "\($0)-\($1)" }
            .sink(receiveValue: object.functionWithOneParemeter)
            .store(in: &subscriptions)

        secondary.send(1)
        primary.send("A")
        secondary.send(100) // Won't trigger publisher, waiting on primary to send again.
        secondary.send(2)
        primary.send("B")

        wait(for: object, timeout: 20.0)

        // Then
        XCTAssertEqual(object.capturedValues, ["A-1", "B-2"])
    }


}

