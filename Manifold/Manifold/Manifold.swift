//
//  Manifold.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public class Manifold {
  static let lineEnding = "\r\n"

  private var parts: [Part] = []
  public var boundary: String?
  private let input: InputStream
  private let stitcher: StreamStitcher

  public init() {
    var _input: InputStream?
    var _output: OutputStream?
    Stream.getBoundStreams(
      withBufferSize: 4096,
      inputStream: &_input,
      outputStream: &_output
    )

    guard let input = _input, let output = _output else {
      fatalError(
        "Unable to bind input & output streams, that's practically impossible"
      )
    }

    self.input = input
    self.stitcher = StreamStitcher(writer: StreamWriter(output: output))

    output.schedule(in: .current, forMode: .defaultRunLoopMode)
    input.schedule(in: .current, forMode: .defaultRunLoopMode)

    input.open()
    output.open()
  }
  
  public func append(part: Part) {
    parts.append(part)
  }

  public func getBodyStream() -> InputStream {
    return input
  }

  public func startWriting(completion: (() -> ())? = nil) {
    writeParts(with: stitcher, parts: parts, completion: completion)
  }
  
  private func writeParts(
    with stitcher: StreamStitcher,
    parts: [Part],
    completion: (() -> ())? = nil
  ) {
    guard let part = parts.first else {
      stitcher.stitch(string: "--\(boundary ?? "")--") {
        stitcher.done()
        completion?()
      }
      return
    }

    stitcher.stitch(string: "--\(boundary ?? "")\(Manifold.lineEnding)") {
      part.write(with: stitcher) {
        stitcher.stitch(string: Manifold.lineEnding) {
          self.writeParts(
            with: stitcher,
            parts: Array(parts[1..<parts.count]),
            completion: completion
          )
        }
      }
    }
  }
}
