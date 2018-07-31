//
//  StreamWriterTestCase.swift
//  ManifoldTests
//
//  Created by pivotal on 7/26/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
import Manifold

//class TestStreamWriterDelegate : StreamWriterDelegate {
//  var hasBytesAvailable = false
//
//  func streamWriterHasSpaceAvailable(_: StreamWriter) {
//    hasBytesAvailable = true
//  }
//}
//
//class StreamWriterTestCase: XCTestCase {
//  func test_write_writesGivenChunkToOutputStream() {
//    var input: InputStream?
//    var output: OutputStream?
//    Stream.getBoundStreams(
//      withBufferSize: 4096,
//      inputStream: &input,
//      outputStream: &output
//    )
//
//    let streamWriter = StreamWriter(output: output!)
//    let testDelegate = TestStreamWriterDelegate()
//    streamWriter.delegate = testDelegate
//    output?.schedule(in: .current, forMode: .commonModes)
//    output!.open()
//
//    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
//    XCTAssertTrue(testDelegate.hasBytesAvailable)
//
//    if(testDelegate.hasBytesAvailable) {
//      let data = "hello world".data(using: .utf8)!
//      streamWriter.write(data)
//      let string = String(data: quickRead(input: input!), encoding: .utf8)
//      XCTAssertNotNil(string)
//
//      if let realString = string {
//        XCTAssertEqual(realString, "hello world")
//      }
//    }
//
//    output!.close()
//  }
//}
