//
//  StreamWriter.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class StreamWriter: NSObject, StreamDelegate {
  private let stream: OutputStream
  private var data: Data
  private var canWriteImmediately: Bool = false
  private var isDone: Bool = false
  
  public init(stream: OutputStream) {
    self.stream = stream
    
    self.data = Data()
    
    super.init()
    
    self.stream.delegate = self
    self.stream.schedule(in: .current, forMode: .defaultRunLoopMode)
    self.stream.open()
  }
  
  public func append(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    
    append(data)
  }
  
  public func append(bytes: UnsafeRawPointer, count: Int) {
    append(Data(bytes: bytes, count: count))
  }
  
  public func append(_ data: Data) {
    self.data.append(data)
    
    if(canWriteImmediately) {
      canWriteImmediately = false
      writeNextChunk()
    }
  }
  
  public func done() {
    isDone = true
    
    if data.isEmpty {
      finish()
    }
  }
  
  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.hasSpaceAvailable:
      if(data.isEmpty && isDone) {
        finish()
      }
      else if data.isEmpty {
        canWriteImmediately = true
      }
      else {
        writeNextChunk()
      }
    default:
      break
    }
  }
  
  private func writeNextChunk() {
    let numBytesWritten = data.withUnsafeBytes { bytes in
      self.stream.write(bytes, maxLength: data.count)
    }

    if(numBytesWritten == -1) {
      if let error = stream.streamError {
        print(error)
      }
      else {
        print("an error occurred while trying to write some data")
      }
      return
    }
    
    if(numBytesWritten == data.count) {
      data = Data()
    }
    else {
      data = data.advanced(by: numBytesWritten)
    }
    
    if(data.isEmpty && isDone) {
      finish()
    }
  }
  
  private func finish() {
    stream.close()
  }
}

