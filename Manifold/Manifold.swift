//
//  Manifold.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class Manifold {
  private var parts: [Part] = []
  public var boundary: String?
  
  public init() {
    
  }
  
  public func append(part: Part) {
    parts.append(part)
  }
  
  public func getBodyStream() -> InputStream {
    var _input: InputStream?
    var _output: OutputStream?
    Stream.getBoundStreams(withBufferSize: 4096, inputStream: &_input, outputStream: &_output)
    
    guard let input = _input, let output = _output else {
      fatalError("Unable to bind input & output streams, that's practically impossible")
    }
    
    let writer = StreamWriter(stream: output)
    writeParts(with: writer, parts: parts)
    
    return input
  }
  
  private func writeParts(with writer: StreamWriter, parts: [Part]) {
    if let part = parts.first {
      if let boundary = boundary {
        writer.append("--\(boundary)")
      }
      
      writer.append("\n")
      part.write(with: writer) {
        writer.append("\n")
        self.writeParts(
          with: writer,
          parts: Array(parts[1..<parts.count])
        )
      }
    }
    else {
      if let boundary = boundary {
        writer.append("--\(boundary)--")
      }
      
      writer.done()
    }
  }
}
