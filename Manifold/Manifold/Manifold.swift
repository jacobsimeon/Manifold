//
//  Manifold.swift
//  Manifold
//
//  Created by pivotal on 6/29/18.
//  Copyright © 2018 PivotalTracker. All rights reserved.
//

import Foundation

public protocol ManifoldDelegate : class {
  func manifold(_ manifold: Manifold, didFinishEncoding stream: InputStream)
}

public class Manifold {
  static let lineEnding = "\r\n"

  public weak var delegate: ManifoldDelegate?
  public var boundary: String?

  private var segments: [InputStream] = []
  private var parts: [Part] = []

  public let fileURL: URL
  private let output: OutputStream
  private let stitcher: StreamStitcher

  private var isOutputStreamOpen = false
  private var shouldBeginEncodingOnStreamOpen = false

  public init() {
    self.fileURL = Manifold.getTempFile()
    self.output = OutputStream(url: fileURL, append: true)!
    self.stitcher = StreamStitcher(writer: StreamWriter(output: output))
    self.stitcher.delegate = self

    self.output.schedule(in: .current, forMode: .defaultRunLoopMode)
    self.output.open()
  }
  
  public func append(part: Part) {
    parts.append(part)
  }

  private func i(_ string: String) -> InputStream {
    guard let data = string.data(using: .utf8) else {
      fatalError("Unable to encode \(string) as UTF8")
    }

    return InputStream(data: data)
  }

  public func encode() {
    guard let boundary = boundary else {
      fatalError("Set boundary first")
    }

    parts.forEach { part in
      segments.append(i("--\(boundary)\(Manifold.lineEnding)"))
      part.headers.forEach { (key, value) in
        segments.append(i("\(key): \(value)\(Manifold.lineEnding)"))
      }
      segments.append(i(Manifold.lineEnding))
      segments.append(part.body!)
      segments.append(i(Manifold.lineEnding))
    }

    segments.append(i("--\(boundary)--"))

    writeNextSegment()
  }

  private func writeNextSegment() {
    guard !segments.isEmpty else {
      stitcher.done()
      return
    }

    let segment = self.segments.removeFirst()
    self.stitcher.stitch(input: segment)
  }

  static func getTempFile() -> URL {
    let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
    let tempFileURL = tempDirURL.appendingPathComponent(UUID().uuidString)

    FileManager.default.createFile(
      atPath: tempFileURL.path,
      contents: nil,
      attributes: nil
    )

    print(tempFileURL)
    return tempFileURL
  }

}

extension Manifold : StreamStitcherDelegate {
  func streamStitcherDidFinishStitchingStream(_ stitcher: StreamStitcher) {
    self.writeNextSegment()
  }

  func streamStitcherDidCloseStream(_ stitcher: StreamStitcher) {
    delegate?.manifold(self, didFinishEncoding: InputStream(url: self.fileURL)!)
  }
}
