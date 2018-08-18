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
  func manifold(_ manifold: Manifold, didFailWithError error: Error)
}

public class Manifold {
  static let lineEnding = "\r\n"

  public weak var delegate: ManifoldDelegate?
  public var boundary: String?

  private var segments: [InputStream] = []
  private var parts: [Part] = []

  public let fileURL: URL
  private let stitcher: StreamStitcher

  public convenience init() {
    let fileURL = Manifold.getTempFile()
    let output = OutputStream(url: fileURL, append: true)!
    let stitcher = IOStreamStitcher(
      writer: OutputStreamWriter(output: output),
      readerFactory: InputStreamReaderFactory()
    )

    self.init(stitcher: stitcher, fileURL: fileURL)
  }

  public init(stitcher: StreamStitcher, fileURL: URL) {
    self.fileURL = fileURL
    self.stitcher = stitcher

    self.stitcher.delegate = self
  }
  
  public func append(part: Part) {
    parts.append(part)
  }

  public func encode() {
    guard let boundary = boundary else {
      fatalError("Set boundary first")
    }

    parts.forEach { part in
      segments.append(Manifold.i("--\(boundary)\(Manifold.lineEnding)"))
      part.headers.forEach { (key, value) in
        segments.append(Manifold.i("\(key): \(value)\(Manifold.lineEnding)"))
      }
      segments.append(Manifold.i(Manifold.lineEnding))
      if let body = part.body {
        segments.append(body)
      }
      segments.append(Manifold.i(Manifold.lineEnding))
    }

    segments.append(Manifold.i("--\(boundary)--"))

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

  private static func getTempFile() -> URL {
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

  private static func i(_ string: String) -> InputStream {
    guard let data = string.data(using: .utf8) else {
      fatalError("Unable to encode \(string) as UTF8")
    }

    return InputStream(data: data)
  }
}

extension Manifold : StreamStitcherDelegate {
  public func streamStitcher(
    _ stitcher: StreamStitcher,
    didFailWithError error: Error
  ) {
    delegate?.manifold(self, didFailWithError: error)
  }

  public func streamStitcherDidCloseStream(_ stitcher: StreamStitcher) {
    guard let input = InputStream(url: fileURL) else {
      let message = "Manifold: Unable to create input stream for \(fileURL)"
      let error = ManifoldError.generic(message)
      delegate?.manifold(self, didFailWithError: error)
      return
    }

    delegate?.manifold(self, didFinishEncoding: input)
  }

  public func streamStitcherDidFinishStitchingStream(
    _ stitcher: StreamStitcher
  ) {
    writeNextSegment()
  }
}
