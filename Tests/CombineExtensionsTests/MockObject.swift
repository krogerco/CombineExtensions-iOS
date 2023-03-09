//
//  File.swift
//
//
//  Created by Isaac Ruiz on 2/22/23.
//

import Foundation
import XCTest

class MockObject<T> {

    let expectation = XCTestExpectation(description: "sample object done")
    var capturedValues: [T] = []
    var functionCalls: Int = 0

    init(fulfillCount: Int = 1) {
        expectation.expectedFulfillmentCount = fulfillCount
    }

    func functionWithOneParemeter(value: T) {
        functionCalls += 1
        capturedValues.append(value)
        expectation.fulfill()
    }

    func functionWithZeroParemeters() {
        functionCalls += 1
        expectation.fulfill()
    }
}

extension XCTestCase {
    func wait<T>(for object: MockObject<T>, timeout: TimeInterval = 0.25) {
        wait(for: [object.expectation], timeout: timeout)
    }
}
