//
//  StreamWriterTestCase.swift
//  ManifoldTests
//
//  Created by pivotal on 8/1/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
@testable import Manifold

class OutputStreamWriterTestCase: XCTestCase {
  func test_notifiesDelegateOfStreamError() {
    let delegate = TestStreamWriterDelegate()
    var error: Error!
    delegate.onStreamWriterDidFailWithError { (writer, err) in
      error = err
    }

    let stream = FakeOutputStream()
    let writer = OutputStreamWriter(output: stream)
    writer.delegate = delegate

    stream.streamError = ManifoldTestsError.anError
    writer.stream(Stream(), handle: Stream.Event.errorOccurred)

    guard let manifoldError = error as? ManifoldError else {
      XCTFail("Expected a ManifoldError but got \(error)")
      return
    }

    guard case let ManifoldError.streamWriteError(e) = manifoldError else {
      XCTFail("Expected streamWriteError but got \(manifoldError)")
      return
    }

    guard let innerError = e as? ManifoldTestsError else {
      XCTFail("Inner error is incorrect type")
      return
    }

    XCTAssertNotNil(error)
    XCTAssertTrue(error is ManifoldError)
    XCTAssertEqual(innerError, ManifoldTestsError.anError)
  }
}


