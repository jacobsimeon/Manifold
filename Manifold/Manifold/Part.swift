//
//  Part.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class Part {
  private var reader: StreamReader?
  private var headers: [String: String]
  
  public init() {
    headers = [:]
  }
  
  public func header(_ name: String, _ value: String) {
    headers[name] = value
  }
  
  public func body(_ body: InputStream) {
    reader = StreamReader(stream: body)
  }
  
  func write(with writer: StreamWriter, completion: @escaping () -> ()) {
    for (key, value) in headers {
      writer.append("\(key): \(value)\(Manifold.lineEnding)")
    }
    
    writer.append(Manifold.lineEnding)
    
    reader?.read(
      onChunkRead: { (bytes, count) in
        writer.append(bytes: bytes, count: count)
      },
      onComplete: {
        completion()
      }
    )
  }
  
}
