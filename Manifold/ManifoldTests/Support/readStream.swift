//
//  readStream.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
import Manifold

public func quickRead(input: InputStream) -> Data {
  input.open()
  var data = Data()

  let bufferSize = 1024
  let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
  while input.hasBytesAvailable {
    let read = input.read(buffer, maxLength: bufferSize)
    data.append(buffer, count: read)
  }
  buffer.deallocate()

  return data
}

public class TestStreamReader: NSObject, StreamDelegate {
  private let stream: InputStream
  private var onChunkRead: ((UnsafeMutablePointer<UInt8>, Int) -> ())?
  private var onComplete: (() -> ())?

  public init(stream: InputStream) {
    self.stream = stream

    super.init()

    self.stream.delegate = self
    self.stream.schedule(in: .current, forMode: .defaultRunLoopMode)
  }

  public func read(
    onChunkRead: @escaping (UnsafeMutablePointer<UInt8>, Int) -> (),
    onComplete: @escaping () -> ()
  ) {
    self.onChunkRead = onChunkRead
    self.onComplete = onComplete

    self.stream.open()
  }

  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch(eventCode) {
    case Stream.Event.hasBytesAvailable:
      let bufferSize = 4096
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
      let numBytesRead = stream.read(buffer, maxLength: bufferSize)

      if(numBytesRead > 0) {
        self.onChunkRead?(buffer, numBytesRead)
      }
    case Stream.Event.endEncountered:
      onComplete?()
    default:
      break
    }
  }
}
