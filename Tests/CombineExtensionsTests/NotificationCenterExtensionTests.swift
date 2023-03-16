//
//  NotificationCenterExtensionTests.swift
//  
//
//  Created by Isaac Ruiz on 3/8/23.
//

import XCTest
import Combine

final class NotificationCenterExtensionTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func testMergeManyNotificationNames() {

        // Given
        let nameA = Notification.Name("A")
        let nameB = Notification.Name("B")
        let nameC = Notification.Name("C")
        let object = MockObject<Notification>(fulfillCount: 3)

        let names: [Notification.Name] = [nameA, nameB, nameC]
        let nc = NotificationCenter()

        nc.publisher(for: names)
            .sink(to: MockObject<Notification>.functionWithOneParemeter, on: object, ownership: .strong)
            .store(in: &subscriptions)

        // When
        nc.post(name: nameA, object: nil)
        nc.post(name: nameB, object: nil)
        nc.post(name: nameC, object: nil)

        // Then
        wait(for: object)

        XCTAssertEqual(object.capturedValues.map { $0.name.rawValue }, ["A", "B", "C"])
    }

    func testMergeManyNotificationNames_dedupe() {

        // Given
        let nameA = Notification.Name("A")
        let object = MockObject<Notification>(fulfillCount: 1, assertForOverFulfill: true)

        let names: [Notification.Name] = [nameA, nameA, nameA] // Adding multiples of the same Name, but only want one notification.
        let nc = NotificationCenter()

        nc.publisher(for: names)
            .sink(receiveValue: object.functionWithOneParemeter)
            .store(in: &subscriptions)

        // When
        nc.post(name: nameA, object: nil)

        // Then
        wait(for: object)

        XCTAssertEqual(object.capturedValues.map { $0.name.rawValue }, ["A"])
    }
}
