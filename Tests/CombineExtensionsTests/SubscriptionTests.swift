import XCTest
import SwiftUI
import Combine
@testable import CombineExtensions

final class SinkTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    func testSinkTo_zeroParameterFunction_weak() {

        // Given
        let object = MockObject<Void>()

        Just("weak")
            .sink(to: MockObject<Void>.functionWithZeroParemeters, on: object, ownership: .weak)
            .store(in: &subscriptions)

        wait(for: object)

        XCTAssertEqual(object.functionCalls, 1)
    }

    func testSinkTo_zeroParameterFunction_strong() {

        // Given
        let object = MockObject<Void>()

        Just("strong")
            .sink(to: MockObject<Void>.functionWithZeroParemeters, on: object, ownership: .strong)
            .store(in: &subscriptions)

        wait(for: object)

        XCTAssertEqual(object.functionCalls, 1)
    }

    func testSinkTo_singleParamterFunction_weak() {

        // Given
        let object = MockObject<String>()

        // When
        Just("weak")
            .sink(to: MockObject<String>.functionWithOneParemeter, on: object, ownership: .weak)
            .store(in: &subscriptions)

        wait(for: object)

        // Then
        XCTAssertEqual(object.capturedValues, ["weak"])
    }

    func testSinkTo_singleParamterFunction_strong() {
        // Given
        let object = MockObject<String>()

        // When
        Just("strong")
            .sink(to: MockObject<String>.functionWithOneParemeter, on: object, ownership: .strong)
            .store(in: &subscriptions)

        wait(for: object)

        // Then
        XCTAssertEqual(object.capturedValues, ["strong"])
    }

    func testSinkTo_zeroParameterFunction_weak_weaklyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.functionWithZeroParemeters, on: weakObject!, ownership: .weak)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNil(weakObject)
    }

    func testSinkTo_zeroParameterFunction_weak_stronglyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.functionWithZeroParemeters, on: weakObject!, ownership: .strong)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNotNil(weakObject)
    }

    func testSinkTo_singleParameterFunction_weak_weaklyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.functionWithZeroParemeters, on: weakObject!, ownership: .weak)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNil(weakObject)
    }

    func testSinkTo_singleParameterFunction_weak_stronglyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .sink(to: MockObject<String>.functionWithZeroParemeters, on: weakObject!, ownership: .strong)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNotNil(weakObject)
    }

    // MAKR: - Assign To

    func testAssignTo_weak() {

        // Given
        let object = MockObject<String>()

        // When
        Just(["weak"])
            .assign(to: \.capturedValues, on: object, ownership: .weak)
            .store(in: &subscriptions)

        // Then
        XCTAssertEqual(object.capturedValues, ["weak"])
    }

    func testAssignTo_strong() {

        // Given
        let object = MockObject<String>()

        // When
        Just(["strong"])
            .assign(to: \.capturedValues, on: object, ownership: .strong)
            .store(in: &subscriptions)

        // Then
        XCTAssertEqual(object.capturedValues, ["strong"])
    }

    func testAssignTo_weaklyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .collect()
            .assign(to: \.capturedValues, on: weakObject!, ownership: .weak)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNil(weakObject)
    }

    func testAssignTo_stronglyRetains() {

        // Given
        var object: MockObject<String>? = MockObject<String>()
        weak var weakObject = object

        let publisher = CurrentValueSubject<String, Never>("String")

        publisher
            .collect()
            .assign(to: \.capturedValues, on: weakObject!, ownership: .strong)
            .store(in: &subscriptions)

        XCTAssertNotNil(weakObject)

        // When
        object = nil

        // Then
        XCTAssertNotNil(weakObject)
    }
}
