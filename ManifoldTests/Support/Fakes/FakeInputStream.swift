//
//  FakeInputStream.swift
//  ManifoldTests
//
//  Created by pivotal on 8/2/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
@testable import Manifold

class FakeInputStream: InputStreamProtocol {
  var delegate: StreamDelegate?
  var streamError: Error?

  func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
    return 0
  }

  func close() {
  }

  func open() {
  }

  func schedule(in aRunLoop: RunLoop, forMode mode: RunLoopMode) {
  }

  func remove(from aRunLoop: RunLoop, forMode mode: RunLoopMode) {
  }
}
