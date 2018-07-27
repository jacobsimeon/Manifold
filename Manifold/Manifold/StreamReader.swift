//
//  StreamReader.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol StreamReaderDelegate : class {
  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data)
  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader)
}

public class StreamReader: NSObject, StreamDelegate {
  weak public var delegate: StreamReaderDelegate?
  private let input: InputStream
  private var isReadyToRead = false
  private var canReadImmediately = false

  public init(input: InputStream) {
    self.input = input

    super.init()

    input.delegate = self
    input.schedule(in: .current, forMode: .commonModes)
  }

  func openStream() {
    input.open()
  }

  func close() {
    input.close()
  }

  public func read() {
    isReadyToRead = true
    if(canReadImmediately) {
      doRead()
      canReadImmediately = false
    }
  }

  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.openCompleted:
      break
    case Stream.Event.hasBytesAvailable:
      print("bytes available")
      if(isReadyToRead) {
        doRead()
        isReadyToRead = false
      } else {
        canReadImmediately = true
      }
    case Stream.Event.hasSpaceAvailable:
      break
    case Stream.Event.errorOccurred:
      break
    case Stream.Event.endEncountered:
      delegate?.streamReaderDidReachEndOfStream(self)
    default:
      break
    }
  }

  private func doRead() {
    let maxLength = 4096
    let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: maxLength)
    let bytesRead = input.read(bytes, maxLength: maxLength)

    let dataRead = Data(bytes: bytes, count: bytesRead)
    delegate?.streamReader(self, didReadChunk: dataRead)
  }
}
