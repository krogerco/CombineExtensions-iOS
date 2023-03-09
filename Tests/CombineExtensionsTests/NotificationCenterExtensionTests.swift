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

    func testMergeManyNotificationNames_nilObject() {

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

    func testMergeManyNotificationNames_withObject() {

        // Given
        class NotificationPoster { }

        let posterA = NotificationPoster()
        let posterB = NotificationPoster()

        let nameA = Notification.Name("A")
        let nameB = Notification.Name("B")
        let nameC = Notification.Name("C")
        let nameD = Notification.Name("D")

        let object = MockObject<Notification>(fulfillCount: 4)

        let names: [Notification.Name] = [nameA, nameB, nameC, nameD]
        let nc = NotificationCenter()

        nc.publisher(for: names, object: posterA)
            .sink(receiveValue: object.functionWithOneParemeter)
            .store(in: &subscriptions)

        // When

        // Expect these to be ignored
        nc.post(name: nameD, object: posterB)
        nc.post(name: nameA, object: posterB)
        nc.post(name: nameA, object: nil)
        nc.post(name: nameD, object: nil)

        // Expect these to be captured
        nc.post(name: nameA, object: posterA)
        nc.post(name: nameB, object: posterA)
        nc.post(name: nameC, object: posterA)
        nc.post(name: nameD, object: posterA)

        // Then
        wait(for: object)

        XCTAssertEqual(object.capturedValues.map { $0.name.rawValue }, ["A", "B", "C", "D"])
    }
}
