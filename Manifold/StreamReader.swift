//
//  StreamReader.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

protocol StreamReaderDelegate : class {
  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data)
  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader)
  func streamReader(_ streamReader: StreamReader, didFailWithError error: Error)
}

protocol StreamReader {
  var delegate: StreamReaderDelegate? { get set }

  func open()
  func close()
}

class InputStreamReader: NSObject, StreamReader {
  weak public var delegate: StreamReaderDelegate?
  private let input: InputStreamProtocol

  public init(input: InputStreamProtocol) {
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

  private func doRead() {
    let maxLength = 4096
    let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: maxLength)
    let bytesRead = input.read(bytes, maxLength: maxLength)

    let dataRead = Data(bytes: bytes, count: bytesRead)
    delegate?.streamReader(self, didReadChunk: dataRead)
    bytes.deallocate()
  }
}

extension InputStreamReader : StreamDelegate {
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.hasBytesAvailable:
      doRead()
    case Stream.Event.errorOccurred:
      let error = ManifoldError.streamReadError(input.streamError)
      delegate?.streamReader(self, didFailWithError: error)
    case Stream.Event.endEncountered:
      close()
      delegate?.streamReaderDidReachEndOfStream(self)
    default:
      break
    }
  }
}
