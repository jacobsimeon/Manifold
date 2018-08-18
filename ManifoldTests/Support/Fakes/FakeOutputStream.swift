//
//  FakeOutputStream.swift
//  ManifoldTests
//
//  Created by pivotal on 8/1/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
@testable import Manifold

class FakeOutputStream: OutputStreamProtocol {
  weak var delegate: StreamDelegate?

  var streamError: Error?

  func open() {
  }

  func schedule(in aRunLoop: RunLoop, forMode mode: RunLoopMode) {
  }

  func remove(from aRunLoop: RunLoop, forMode mode: RunLoopMode) {
  }

  func close() {
  }

  func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
    return 0
  }
}
