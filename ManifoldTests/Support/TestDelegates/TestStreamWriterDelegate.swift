//
//  TestStreamWriterDelegate.swift
//  ManifoldTests
//
//  Created by pivotal on 8/14/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import XCTest

@testable
import Manifold

class TestStreamWriterDelegate: NSObject, StreamWriterDelegate {
  private var streamWriterDidCloseStreamImpl: ((StreamWriter) -> ())?
  private var streamWriterDidFailWithErrorImpl: ((StreamWriter, Error) -> ())?

  func streamWriterDidCloseStream(_ streamWriter: StreamWriter) {
    streamWriterDidCloseStreamImpl?(streamWriter)
  }

  func onStreamWriterDidCloseStream(_ impl: @escaping (StreamWriter) -> ()) {
    streamWriterDidCloseStreamImpl = impl
  }

  func streamWriter(
    _ streamWriter: StreamWriter,
    didFailWithError error: Error
  ) {
    streamWriterDidFailWithErrorImpl?(streamWriter, error)
  }

  func onStreamWriterDidFailWithError(
    _ impl: @escaping (StreamWriter, Error) -> ()
  ) {
    streamWriterDidFailWithErrorImpl = impl
  }
}
