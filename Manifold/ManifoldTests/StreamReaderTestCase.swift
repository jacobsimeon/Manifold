//
//  StreamStitcherTest.swift
//  ManifoldTests
//
//  Created by pivotal on 7/26/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest
import Manifold

//class StreamReaderTestDelegate : StreamReaderDelegate {
//  var didReachEndOfStream = false
//  var data = Data()
//  var dataString: String {
//    return String(data: data, encoding: .utf8)!
//  }
//
//  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data) {
//    data.append(chunk)
//  }
//
//  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader) {
//    didReachEndOfStream = true
//  }
//}
//
//class StreamReaderTestCase: XCTestCase {
//  func test_StreamReader_callsDelegateWithChunk() {
//    let stream = InputStream(data: "hello world".data(using: .utf8)!)
//    let testDelegate = StreamReaderTestDelegate()
//
//    let reader = StreamReader(input: stream)
//    reader.delegate = testDelegate
//    stream.open()
//
//    reader.read()
//    XCTAssertTrue(testDelegate.data.isEmpty)
//
//    reader.stream(stream, handle: Stream.Event.hasBytesAvailable)
//    XCTAssertEqual(testDelegate.dataString, "hello world")
//  }
//
//  func test_StreamReader_waitsUntilCanRead_beforeReading() {
//    let stream = InputStream(data: "hello world".data(using: .utf8)!)
//    let testDelegate = StreamReaderTestDelegate()
//
//    let reader = StreamReader(input: stream)
//    reader.delegate = testDelegate
//    stream.schedule(in: .current, forMode: .commonModes)
//    stream.open()
//
//    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
//    XCTAssertTrue(testDelegate.data.isEmpty)
//
//    reader.read()
//    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
//    XCTAssertEqual(testDelegate.dataString, "hello world")
//    XCTAssertTrue(testDelegate.didReachEndOfStream)
//
//    stream.close()
//  }
//}
