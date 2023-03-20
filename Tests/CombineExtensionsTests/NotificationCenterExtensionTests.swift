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
        let notificationCenter = NotificationCenter()

        notificationCenter.publisher(for: names)
            .sink(to: MockObject<Notification>.functionWithOneParemeter, on: object, ownership: .strong)
            .store(in: &subscriptions)

        // When
        notificationCenter.post(name: nameA, object: nil)
        notificationCenter.post(name: nameB, object: nil)
        notificationCenter.post(name: nameC, object: nil)

        // Then
        wait(for: object)

        XCTAssertEqual(object.capturedValues.map { $0.name.rawValue }, ["A", "B", "C"])
    }

    func testMergeManyNotificationNames_dedupe() {

        // Given
        let nameA = Notification.Name("A")
        let object = MockObject<Notification>(fulfillCount: 1, assertForOverFulfill: true)

        let names: [Notification.Name] = [nameA, nameA, nameA] // Adding multiples of the same Name, but only want one notification.
        let notificationCenter = NotificationCenter()

        notificationCenter.publisher(for: names)
            .sink(receiveValue: object.functionWithOneParemeter)
            .store(in: &subscriptions)

        // When
        notificationCenter.post(name: nameA, object: nil)

        // Then
        wait(for: object)

        XCTAssertEqual(object.capturedValues.map { $0.name.rawValue }, ["A"])
    }
}
