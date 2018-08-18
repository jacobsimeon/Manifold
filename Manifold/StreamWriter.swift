//
//  StreamWriter.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

protocol StreamWriterDelegate: class {
  func streamWriterDidCloseStream(_ streamWriter: StreamWriter)
  func streamWriter(_ streamWriter: StreamWriter, didFailWithError error: Error)
}

protocol StreamWriter: class {
  var delegate: StreamWriterDelegate? { get set }
    
  func write(_ data: Data)
  func open()
  func done()
}

class OutputStreamWriter: NSObject, StreamWriter {
  public weak var delegate: StreamWriterDelegate?

  private let output: OutputStreamProtocol
  private var data: Data

  private var canWriteImmediately = false
  private var isDone = false

  public init(output: OutputStreamProtocol) {
    self.output = output
    self.data = Data()

    super.init()

    self.output.delegate = self
  }

  public func write(_ data: Data) {
    self.data.append(data)

    if(canWriteImmediately) {
      canWriteImmediately = false
      doWrite()
    }
  }

  public func open() {
    output.schedule(in: .current, forMode: .defaultRunLoopMode)
    output.open()
  }

  public func done() {
    isDone = true

    if(isReadyToClose) {
      close()
    }
  }

  private var isReadyToClose: Bool {
    return data.isEmpty && isDone
  }

  private func close() {
    output.close()
    delegate?.streamWriterDidCloseStream(self)
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

extension OutputStreamWriter : StreamDelegate {
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.hasSpaceAvailable:
      doWrite()
    case Stream.Event.errorOccurred:
      let error = ManifoldError.streamWriteError(output.streamError)
      delegate?.streamWriter(self, didFailWithError: error)
    default:
      break
    }
  }
}
