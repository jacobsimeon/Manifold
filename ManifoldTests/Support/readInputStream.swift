//
//  readStream.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
import Manifold

public func read(input: InputStream) -> Data {
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
