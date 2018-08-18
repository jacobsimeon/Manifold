//
//  ManifoldWithLargeFileTest.swift
//  ManifoldTests
//
//  Created by Jacob Morris on 7/30/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
import Manifold

class ManifoldWithLargeFileTestCase: XCTestCase {
  func test_aPartWithLargeFileInputStream_isWrittenSafely() {
    let videoStream = Fixture(name: "random-video.m4v")
    let manifold = Manifold()
    manifold.boundary = "1234567890"

    let part = Part()
    part.body(videoStream.input)
    manifold.append(part: part)

    let delegate = TestManifoldDelegate()
    manifold.delegate = delegate

    let finishedReading = expectation(description: "Finished reading")
    var actualData: Data?
    delegate.onManifoldDidFinishEncoding { _, stream in
      actualData = read(input: stream)
      finishedReading.fulfill()
    }
    manifold.encode()
    waitForExpectations(timeout: 5.0)

    var expectedData = Data()
    expectedData.append("--1234567890\r\n\r\n".data(using: .utf8)!)
    expectedData.append(videoStream.data)
    expectedData.append("\r\n--1234567890--".data(using: .utf8)!)

    XCTAssertEqual(actualData, expectedData)
  }
}
