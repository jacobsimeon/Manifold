//
//  TestStreamReaderDelegate.swift
//  ManifoldTests
//
//  Created by pivotal on 8/2/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
@testable import Manifold

class TestStreamReaderDelegate : NSObject, StreamReaderDelegate {
  var streamReaderDidReadChunkImpl: ((StreamReader, Data) -> ())?
  var streamReaderDidReachEndOfStreamImpl: ((StreamReader) -> ())?
  var streamReaderDidFailWithErrorImpl: ((StreamReader, Error) -> ())?

  func onStreamReaderDidReadChunk(impl: @escaping (StreamReader, Data) -> ()) {
    streamReaderDidReadChunkImpl = impl
  }

  func onStreamReaderDidReachEndOfStream(impl: @escaping (StreamReader) -> ()) {
    streamReaderDidReachEndOfStreamImpl = impl
  }

  func onStreamReaderDidFailWithError(
    impl: @escaping (StreamReader, Error) -> ()
  ) {
    streamReaderDidFailWithErrorImpl = impl
  }

  func streamReader(_ streamReader: StreamReader, didReadChunk chunk: Data) {
    streamReaderDidReadChunkImpl?(streamReader, chunk)
  }

  func streamReaderDidReachEndOfStream(_ streamReader: StreamReader) {
    streamReaderDidReachEndOfStreamImpl?(streamReader)
  }

  func streamReader(
    _ streamReader: StreamReader, didFailWithError error: Error
  ) {
    streamReaderDidFailWithErrorImpl?(streamReader, error)
  }
}
