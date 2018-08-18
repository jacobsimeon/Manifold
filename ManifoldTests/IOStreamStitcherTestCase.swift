//
//  IOStreamStitcherTestCase.swift
//  ManifoldTests
//
//  Created by Pivotal on 8/9/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest

@testable
import Manifold

class IOStreamStitcherTestCase : XCTestCase {
  var fakeWriter: FakeStreamWriter!
  var fakeReaderFactory: FakeStreamReaderFactory!
  var testDelegate: TestStreamStitcherDelegate!
  var lastError: Error?

  override func setUp() {
    fakeWriter = FakeStreamWriter()
    fakeReaderFactory = FakeStreamReaderFactory()
    testDelegate = TestStreamStitcherDelegate()

    testDelegate.onStreamStitcherDidFailWithError { (_, error) in
      self.lastError = error
    }
  }

  func testPropagatesStreamWriterErrorToDelegate() {
    let stitcher = IOStreamStitcher(
      writer: fakeWriter,
      readerFactory: fakeReaderFactory
    )

    stitcher.delegate = testDelegate

    let error = ManifoldTestsError.anError
    fakeWriter.delegate?.streamWriter(fakeWriter, didFailWithError: error)

    XCTAssertTrue(lastError is ManifoldTestsError)
  }
  
  func testPropagatesStreamReaderErrorToDelegate() {
    let stitcher = IOStreamStitcher(
      writer: fakeWriter,
      readerFactory: fakeReaderFactory
    )

    let fakeReader = FakeStreamReader()
    fakeReaderFactory.onStreamReader { _ in return fakeReader }

    stitcher.delegate = testDelegate

    let input = FakeInputStream()
    stitcher.stitch(input: input)

    let error = ManifoldTestsError.anError
    fakeReader.delegate?.streamReader(fakeReader, didFailWithError: error)

    XCTAssertTrue(lastError is ManifoldTestsError)
  }
}
