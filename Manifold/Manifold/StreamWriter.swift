//
//  StreamWriter.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol StreamWriterDelegate: class {
  func streamWriterDidCloseStream(_ streamWriter: StreamWriter)
}

public class StreamWriter: NSObject, StreamDelegate {
  public weak var delegate: StreamWriterDelegate?

  private let output: OutputStream
  private var data: Data

  private var canWriteImmediately = false
  private var isDone = false

  public init(output: OutputStream) {
    self.output = output
    self.data = Data()

    super.init()

    self.output.delegate = self
  }

  var isReadyToClose: Bool {
    return data.isEmpty && isDone
  }

  func done() {
    isDone = true

    if(isReadyToClose) {
      close()
    }
  }

  func close() {
    output.close()
    delegate?.streamWriterDidCloseStream(self)
  }

  public func write(_ data: Data) {
    self.data.append(data)

    if(canWriteImmediately) {
      canWriteImmediately = false
      doWrite()
    }
  }

  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.openCompleted:
      break
    case Stream.Event.hasBytesAvailable:
      break
    case Stream.Event.hasSpaceAvailable:
      doWrite()
    case Stream.Event.errorOccurred:
      break
    case Stream.Event.endEncountered:
      break
    default:
      break
    }
  }

  private func doWrite() {
    if(isReadyToClose) {
      close()
      return
    }

    if data.isEmpty {
      canWriteImmediately = true
      return
    }

    let bytesWritten = data.withUnsafeBytes { bytes in
      output.write(bytes, maxLength: data.count)
    }

    if bytesWritten == data.count {
      data = Data()
    }
    else {
      data = data.advanced(by: bytesWritten)
    }

    if(isReadyToClose) {
      close()
    }
  }
}
