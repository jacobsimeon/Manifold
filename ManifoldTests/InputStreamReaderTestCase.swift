//
//  StreamReaderTestCase.swift
//  ManifoldTests
//
//  Created by pivotal on 8/2/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest

@testable import Manifold

class InputStreamReaderTestCase: XCTestCase {
  func test_notifiesDelegateOfStreamError() {
    let input = FakeInputStream()
    var error: Error!
    let testDelegate = TestStreamReaderDelegate()
    testDelegate.onStreamReaderDidFailWithError { (_, e) in
      error = e
    }

    let reader = InputStreamReader(input: input)
    reader.delegate = testDelegate

    input.streamError = ManifoldTestsError.anError
    reader.stream(InputStream(), handle: Stream.Event.errorOccurred)

    guard let manifoldError = error as? ManifoldError else {
      XCTFail("Expected a ManifoldError but got \(error)")
      return
    }

    guard case let ManifoldError.streamReadError(e) = manifoldError else {
      XCTFail("Expected streamReadError but got \(manifoldError)")
      return
    }

    guard let innerError = e as? ManifoldTestsError else {
      let desc = String(describing: e)
      XCTFail("Expected \(ManifoldTestsError.self) but got \(desc)")
      return
    }

    XCTAssertNotNil(error)
    XCTAssertTrue(error is ManifoldError)
    XCTAssertEqual(innerError, ManifoldTestsError.anError)
  }
}
