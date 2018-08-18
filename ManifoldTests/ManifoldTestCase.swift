//
//  ManifoldTests.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
import Manifold

class ManifoldTestCase: XCTestCase {
  var manifold: Manifold!

  func test_manifold_canWriteAMultipartRequest() {
    manifold = Manifold()
    manifold.boundary = "1234567890"

    let greetingPart = Part()
    greetingPart.header("Content-Type", "text/plain")
    greetingPart.header("X-UserID", "123abc")
    greetingPart.body(inputStream("Hello World"))

    let salutationPart = Part()
    salutationPart.header("Content-Type", "application/json")
    salutationPart.body(inputStream("{\"goodbye\": \"cruel world\"}"))

    manifold.append(part: greetingPart)
    manifold.append(part: salutationPart)

    var fullBody: String?
    let finishedWriting = expectation(description: "Finished writing")
    let delegate = TestManifoldDelegate()
    delegate.onManifoldDidFinishEncoding { _, stream in
      let bodyData = read(input: stream)
      fullBody = String(data: bodyData, encoding: .utf8)!
      finishedWriting.fulfill()
    }

    manifold.delegate = delegate
    manifold.encode()

    waitForExpectations(timeout: 1.0)

    manifold = nil

    let expectedBody = """
    --1234567890\r
    Content-Type: text/plain\r
    X-UserID: 123abc\r
    \r
    Hello World\r
    --1234567890\r
    Content-Type: application/json\r
    \r
    {"goodbye": "cruel world"}\r
    --1234567890--
    """

    XCTAssertEqual(fullBody, expectedBody)
  }

  func testNotifiesDelegateOfEncodingError() {
    let stitcher = FakeStreamStitcher()
    let testDelegate = TestManifoldDelegate()

    let manifold = Manifold(
      stitcher: stitcher,
      fileURL: URL(fileURLWithPath: "/not-a-file")
    )

    manifold.delegate = testDelegate

    var lastError: Error?
    testDelegate.onManifoldDidFailWithError { _, error in
      lastError = error
    }

    let error = ManifoldTestsError.anError
    stitcher.delegate?.streamStitcher(stitcher, didFailWithError: error)

    XCTAssertTrue(lastError is ManifoldTestsError)
  }
}

func inputStream(_ string: String) -> InputStream {
  return InputStream(data: string.data(using: .utf8)!)
}
