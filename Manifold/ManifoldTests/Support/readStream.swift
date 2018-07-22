//
//  readStream.swift
//  ManifoldTests
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation
import Manifold

public func read(input: InputStream, completion: @escaping (String) -> ()) -> StreamReader {
  var data = Data()

  let reader = StreamReader(stream: input)

  reader.read(
    onChunkRead: { (bytes, count) in
      data.append(bytes, count: count)
    },
    onComplete: {
      completion(String(data: data, encoding: .utf8)!)
    }
  )
  
  return reader
}
