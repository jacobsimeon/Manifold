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
  func testExample() {
    let manifold = Manifold()
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
    
    var fullBody: String?
    let finishedReading = expectation(description: "Finished reading the input stream")
    let reader = read(input: bodyStream) { (body) in
      fullBody = body
      finishedReading.fulfill()
    }
    waitForExpectations(timeout: 1.0)
    
    let expectedBody = """
    --1234567890
    Content-Type: text/plain
    X-UserID: 123abc
    
    Hello World
    --1234567890
    Content-Type: application/json
    
    {"goodbye": "cruel world"}
    --1234567890--
    """
    
    XCTAssertEqual(fullBody, expectedBody)
  }
  
}

func inputStream(_ string: String) -> InputStream {
  return InputStream(data: string.data(using: .utf8)!)
}
