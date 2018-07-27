//
//  ManifoldTests.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
import Manifold

class ManifoldTests: XCTestCase {
  let manifold = Manifold()

  func test_manifold_canWriteAMultipartRequest() {
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

    let bodyStream = manifold.getBodyStream()
    manifold.startWriting()
    RunLoop.current.run(until: Date().addingTimeInterval(1.0))

    let fullBody = String(data: quickRead(input: bodyStream), encoding: .utf8)
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
  
}

func inputStream(_ string: String) -> InputStream {
  return InputStream(data: string.data(using: .utf8)!)
}
