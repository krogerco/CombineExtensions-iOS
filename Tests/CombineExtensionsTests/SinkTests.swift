import XCTest
import SwiftUI
import Combine
@testable import CombineExtensions

final class SinkTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func testSink_0_parameters() {

        // Given
        let object = MockObject<Void>()

        Just(34)
            .sink(to: MockObject<Void>.handle0, on: object, ownership: .strong)
            .store(in: &subscriptions)

        wait(for: object)
    }

    func testSink_1_parameters() {
        // Given
        let object = MockObject<String>()

        // When
        Just("strong")
            .sink(to: MockObject<String>.handle, on: object, ownership: .strong)
            .store(in: &subscriptions)

        Just("weak")
            .sink(to: MockObject<String>.handle, on: object, ownership: .weak)
            .store(in: &subscriptions)

        wait(for: object)

        // Then
        XCTAssertEqual(object.capturedValues, ["strong", "weak"])
    }

    func testWeakness() {
        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.handle, on: weakObject!, ownership: .weak)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        object = nil

        XCTAssertNil(weakObject)

    }

    func testStrongness() {
        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.handle, on: weakObject!, ownership: .strong)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        object = nil

        XCTAssertNotNil(weakObject)
    }

}
