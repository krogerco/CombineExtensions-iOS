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

    init(fulfillCount: Int = 1) {
        expectation.expectedFulfillmentCount = fulfillCount
    }

    func functionWithOneParemeter(value: T) {
        capturedValues.append(value)
        expectation.fulfill()
    }

    func functionWithZeroParemeters() {
        expectation.fulfill()
    }
}

extension XCTestCase {
    func wait<T>(for object: MockObject<T>, timeout: TimeInterval = 0.5) {
        wait(for: [object.expectation], timeout: timeout)
    }
}
