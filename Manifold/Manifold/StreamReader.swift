//
//  StreamReader.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol StreamReaderDelegate : class {
  func streamReaderDidReadChunk(_ chunk: Data)
  func streamReaderDidReachEndOfStream()
}

public class StreamReader: NSObject, StreamDelegate {
  weak public var delegate: StreamReaderDelegate?
  private let input: InputStream

  public init(input: InputStream) {
    self.input = input

    super.init()

    input.delegate = self
    input.schedule(in: .current, forMode: .commonModes)
  }

  public func open() {
    input.open()
  }

  public func close() {
    input.close()
  }

  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.openCompleted:
      break
    case Stream.Event.hasBytesAvailable:
      doRead()
    case Stream.Event.hasSpaceAvailable:
      break
    case Stream.Event.errorOccurred:
      break
    case Stream.Event.endEncountered:
      delegate?.streamReaderDidReachEndOfStream()
      close()
    default:
      break
    }
  }

  private func doRead() {
    let maxLength = 4096
    let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: maxLength)
    let bytesRead = input.read(bytes, maxLength: maxLength)

    let dataRead = Data(bytes: bytes, count: bytesRead)
    delegate?.streamReaderDidReadChunk(dataRead)
    bytes.deallocate()
  }
}
