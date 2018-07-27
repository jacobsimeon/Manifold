//
//  StreamWriter.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol StreamWriterDelegate: class {
  func streamWriterHasSpaceAvailable(_: StreamWriter)
}

public class StreamWriter: NSObject, StreamDelegate {
  private let output: OutputStream
  public weak var delegate: StreamWriterDelegate?

  public init(output: OutputStream) {
    self.output = output

    super.init()

    self.output.delegate = self
  }

  func done() {
    output.close()
  }

  public func write(_ data: Data) {
    let bytesWritten = data.withUnsafeBytes { bytes in
      output.write(bytes, maxLength: data.count)
    }
    if let string = String(data: data, encoding: .utf8) {
      print(string)
    }
    else {
      print("wrote \(bytesWritten) bytes")
    }
  }

  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.openCompleted:
      break
    case Stream.Event.hasBytesAvailable:
      break
    case Stream.Event.hasSpaceAvailable:
      print("Space available")
      delegate?.streamWriterHasSpaceAvailable(self)
      break
    case Stream.Event.errorOccurred:
      print("error occurred")
      break
    case Stream.Event.endEncountered:
      break
    default:
      break
    }
  }
}

